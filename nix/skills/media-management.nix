{ config, lib, sensitive, ... }:
let
  tld = "https.${sensitive.lib.tld}";
  sonarr = "https://sonarr.${tld}";
  radarr = "https://radarr.${tld}";
  transmission = "https://transmission.${tld}";
in
{
  services.cowboy.skills.media-management = {
    description = "Manage TV/movie downloads via Sonarr, Radarr, and Transmission";
    autoLoad = true;
    tags = [ "media" "downloads" "sonarr" "radarr" "transmission" ];
    promptText = ''
      # Media Management (Sonarr / Radarr / Transmission)

      Manage TV/movie downloads via the *arr stack and Transmission BitTorrent client.
      Authentication is injected automatically by the proxy — no API keys needed.

      ## Endpoints

      - **Sonarr** (TV): `${sonarr}/api/v3/`
      - **Radarr** (Movies): `${radarr}/api/v3/`
      - **Transmission RPC**: `${transmission}/transmission/rpc`

      ---

      ## Transmission RPC

      Transmission requires a session token. Grab it from the 409 response:

      ```bash
      SID=$(curl -sk ${transmission}/transmission/rpc 2>&1 \
        | grep -oP 'X-Transmission-Session-Id: \K[^\s<]+')
      ```

      Then include `-H "X-Transmission-Session-Id: $SID"` on all requests.

      ### Check torrent status
      ```bash
      curl -sk ${transmission}/transmission/rpc \
        -H "X-Transmission-Session-Id: $SID" \
        -d '{"method":"torrent-get","arguments":{"fields":["id","name","status","percentDone","rateDownload","eta","totalSize","error","errorString","files","metadataPercentComplete"]}}'
      ```

      Status codes: 0=stopped, 1=check-queued, 2=checking, 3=download-queued, 4=downloading, 5=seed-queued, 6=seeding.

      ### Delete a torrent (with local data)
      ```bash
      curl -sk ${transmission}/transmission/rpc \
        -H "X-Transmission-Session-Id: $SID" \
        -d '{"method":"torrent-remove","arguments":{"ids":[ID],"delete-local-data":true}}'
      ```

      ---

      ## Diagnosing Stuck Torrents

      A torrent is **dead** when ALL of these are true:
      - `totalSize` is 0
      - `metadataPercentComplete` is 0
      - `status` is 4 (downloading)
      - It has been in this state for more than ~60 seconds

      This means the magnet link never resolved metadata — no peers have the torrent.

      **Public tracker seeder counts (TPB, LimeTorrents, etc.) are often inflated or
      fake.** Do not trust them. Verify by checking actual metadata resolution in
      Transmission after grabbing.

      ### Fix workflow

      1. **Try restarting Transmission first** — DHT/peer discovery can stall:
         ```bash
         systemctl restart transmission.service
         ```
         Wait ~60s and recheck. If metadata resolves, the torrent was fine and
         Transmission just needed a DHT re-bootstrap.

      2. If still dead after restart, the magnet itself is bad:
         - Remove from Sonarr/Radarr queue with blacklist (see below)
         - Search for alternative releases
         - Force-grab a new one
         - Verify `metadataPercentComplete` > 0 within ~30s

      ---

      ## Sonarr (TV Shows)

      ### Find a series
      ```bash
      curl -sk "${sonarr}/api/v3/series" \
        | jq '[.[] | select(.title | test("QUERY";"i")) | {id, title, tvdbId}]'
      ```

      ### List episodes in a season
      ```bash
      curl -sk "${sonarr}/api/v3/episode?seriesId=ID" \
        | jq '[.[] | select(.seasonNumber == N) | {id, episodeNumber, title, hasFile, monitored}]'
      ```

      ### Check download queue
      ```bash
      curl -sk "${sonarr}/api/v3/queue?includeEpisode=true" \
        | jq '[.records[] | {id, title, status, trackedDownloadStatus, trackedDownloadState, errorMessage}]'
      ```

      ### Remove from queue + blacklist a bad release
      ```bash
      curl -sk "${sonarr}/api/v3/queue/QUEUE_ID" -X DELETE \
        -H "Content-Type: application/json" \
        -d '{"removeFromClient":true,"blocklist":true}'
      ```

      ### Search for alternative releases
      ```bash
      curl -sk "${sonarr}/api/v3/release?episodeId=EPISODE_ID" \
        | jq '[.[] | {title, guid, indexerId, indexer, size, seeders, leechers,
               quality: .quality.quality.name, rejected, rejections}]
               | sort_by(-.seeders)'
      ```

      The `rejected` and `rejections` fields show why Sonarr's automatic search
      skipped a release. Common reasons:
      - Quality not in profile (e.g. "WEBDL-1080p is not wanted in profile")
      - "Release in queue already meets cutoff" — existing queued item blocks grabs
      - "Wrong episode" — multi-episode release matched wrong ep

      ### Force-grab a specific release (bypasses quality profile)
      ```bash
      curl -sk "${sonarr}/api/v3/release" -X POST \
        -H "Content-Type: application/json" \
        -d '{"guid":"RELEASE_GUID","indexerId":INDEXER_ID}'
      ```

      ---

      ## Radarr (Movies)

      Same API patterns as Sonarr but at `${radarr}/api/v3/`. Key differences:
      - `/api/v3/movie` instead of `/api/v3/series`
      - `/api/v3/release?movieId=ID` for searching releases
      - Queue management is identical

      ---

      ## Fake Release Detection

      Some indexers (especially LimeTorrents) serve **malware disguised as media**.
      Known patterns:
      - Files ending in `.exe`, `.scr`, `.bat`, `.msi`, `.vbs`, `.ps1`
      - Often use real release group names (e.g. `h264-ETHEL`)
      - Sonarr's parser reads the title string and misses the extension

      **ALWAYS check file extensions** on completed downloads from public indexers:

      ```bash
      curl -sk ${transmission}/transmission/rpc \
        -H "X-Transmission-Session-Id: $SID" \
        -d '{"method":"torrent-get","arguments":{"fields":["id","name","files"],"ids":[ID]}}' \
        | jq '.arguments.torrents[].files[].name'
      ```

      If ANY file has a suspicious extension: delete the torrent with local data
      immediately and blacklist it in Sonarr/Radarr.

      ---

      ## Service Restarts

      Managed units: `transmission.service`, `sonarr.service`, `radarr.service`,
      `prowlarr.service`, `plex.service`

      ```bash
      systemctl status <unit>
      systemctl restart <unit>
      journalctl -u <unit> -n 50 --no-pager
      ```

      ### When to restart

      - **transmission.service**: When torrents are stuck with no metadata despite
        connectivity. Transmission's DHT/peer discovery can stall and a restart
        re-bootstraps the DHT table. Also restart after VPN (WireGuard) reconnects —
        Transmission binds to the VPN interface IP and won't recover from an IP change
        without a restart.
      - **sonarr.service** / **radarr.service**: If API returns 500s or the queue
        shows stale entries that don't match Transmission state.
      - **prowlarr.service**: If indexer searches return empty results unexpectedly.

      ### Transmission + VPN dependency

      Transmission binds to the WireGuard VPN interface IP for peer traffic.
      If the VPN tunnel drops and reconnects with a new IP, Transmission will
      silently fail to download (no error, just 0 peers). The fix is:
      ```bash
      systemctl restart transmission.service
      ```
    '';
  };
}
