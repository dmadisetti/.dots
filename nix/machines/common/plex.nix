# 🏴 + 🦜= 💰
{ config, pkgs, lib, sensitive, ... }:
let
  pirateInterface = config.networking.wg-quick.interfaces ? pirate;
  interface =
    if pirateInterface then rec {
      # For IP
      endpoint = (lib.last config.networking.wg-quick.interfaces.pirate.peers).endpoint;
      announced = builtins.elemAt (lib.splitString ":" endpoint) 0;

      address = (lib.last config.networking.wg-quick.interfaces.pirate.address);
      ipv4 = builtins.elemAt (lib.splitString "/" address) 0;
      # Private block
      ipv6 = "fe80::";
    } else { };
  pirate = sensitive.lib ? pirate;
  shows = pirate && sensitive.lib.pirate ? sonarrMount;
  movies = pirate && sensitive.lib.pirate ? radarrMount;
  books = pirate && sensitive.lib.pirate ? readarrMount;
  kavita = pirate && (sensitive.lib.pirate ? kavitaKey) && books;
  binds = (
    (if shows then [ sensitive.lib.pirate.sonarrMount ] else [ ]) ++
    (if movies then [ sensitive.lib.pirate.radarrMount ] else [ ]) ++
    (if books then [ sensitive.lib.pirate.readarrMount ] else [ ])
  );
  # Testing. Is it transmission that does the moving?
  maybeGroup = { name, enable }:
    if enable then {
      "${name}".extraGroups = [ "plex" "transmission" ];
    }
    else { };
  transmissionGroup = { name, enable }:
    if enable then [ name ] else [ ];

  # Hardening template mirroring what nixpkgs gives sonarr/radarr (~score 1.5).
  # Applied to prowlarr/readarr/kavita whose nixpkgs modules never received the
  # same treatment (they sit at 8.2/9.2/9.2 unmitigated). MemoryDenyWriteExecute
  # is intentionally left at the upstream default (off) because the .NET JIT
  # uses RWX mappings during code generation — sonarr has it off too.
  arrHarden = {
    NoNewPrivileges = true;
    PrivateDevices = true;
    PrivateTmp = true;
    PrivateUsers = true;
    ProtectClock = true;
    ProtectControlGroups = true;
    ProtectHome = lib.mkForce true;
    ProtectHostname = true;
    ProtectKernelLogs = true;
    ProtectKernelModules = true;
    ProtectKernelTunables = true;
    ProtectProc = "invisible";
    RemoveIPC = true;
    RestrictAddressFamilies = [ "AF_INET" "AF_INET6" "AF_UNIX" ];
    RestrictNamespaces = true;
    RestrictRealtime = true;
    RestrictSUIDSGID = true;
    LockPersonality = true;
    SystemCallArchitectures = "native";
    SystemCallFilter = [ "@system-service" ];
    CapabilityBoundingSet = "";
    AmbientCapabilities = "";
  };
in
{
  environment.systemPackages = with pkgs; [ mediainfo ];

  # Set group on the services to allow for file movement
  users.users = (
    (maybeGroup { name = "radarr"; enable = movies; }) //
      (maybeGroup { name = "sonarr"; enable = shows; }) //
      (maybeGroup { name = "readarr"; enable = books; })
  ) // {
    transmission.extraGroups = [ "plex" ] ++
      (transmissionGroup { name = "radarr"; enable = movies; }) ++
        (transmissionGroup { name = "sonarr"; enable = shows; }) ++
        (transmissionGroup { name = "readarr"; enable = books; });
  };

  services = {
    plex = {
      enable = true;
      openFirewall = true;
      dataDir = "/media/plex";
      extraPlugins =
        if books then [
          (builtins.path {
            name = "Audnexus.bundle";
            path = pkgs.fetchFromGitHub {
              owner = "djdembeck";
              repo = "Audnexus.bundle";
              rev = "v0.2.8";
              sha256 = "sha256-IWOSz3vYL7zhdHan468xNc6C/eQ2C2BukQlaJNLXh7E=";
            };
          })
        ] else [ ];
    };
    sonarr = {
      enable = shows;
      openFirewall = shows;
      group = "plex";
    };
    radarr = {
      enable = movies;
      openFirewall = movies;
      group = "plex";
    };
    readarr = {
      enable = books;
      openFirewall = books;
      group = "plex";
    };
    prowlarr = {
      enable = true;
      openFirewall = true;
    };

    kavita = {
      enable = kavita;
      tokenKeyFile = if kavita then sensitive.lib.pirate.kavitaKey else null;
    };

    transmission = {
      enable = true;
      package = pkgs.transmission_4;
      settings = {
        download-dir = "/media/downloads/unsorted";
        incomplete-dir = "/media/downloads/processing";
        incomplete-dir-enabled = true;
        rpc-whitelist = "127.0.0.1,192.168.*.*,10.13.37.*,10.1.1.*";
        # Change listening ip
        # rpc-bind-address = lib.mkForce interface.ipv4;
        bind-address-ipv4 = lib.mkForce interface.ipv4;
        bind-address-ipv6 = lib.mkForce interface.ipv6;
        announce-ip = lib.mkForce interface.announced;
        announce-ip-enabled = true;
      };
    };
  };
  # plex is already partially hardened by nixpkgs (LockPersonality,
  # MemoryDenyWriteExecute, ProtectSystem=yes, etc). The 7.0 score is almost
  # entirely an uncleared CapabilityBoundingSet. Plex runs as a normal user
  # and binds to high port 32400, so no caps are needed.
  # Deliberately NOT setting PrivateDevices=true (would break /dev/dri HW
  # transcoding) or PrivateUsers=true (risks UID mapping issues with the shared
  # plex-group media library ownership).
  systemd.services.plex.serviceConfig = {
    KillSignal = lib.mkForce "SIGKILL";
    CapabilityBoundingSet = "";
    AmbientCapabilities = "";
    ProtectClock = true;
    ProtectHostname = true;
    ProtectKernelLogs = true;
    ProtectProc = "invisible";
    RemoveIPC = true;
    RestrictNamespaces = true;
  };

  # Apply the sonarr-equivalent hardening template to the *arr siblings whose
  # nixpkgs modules never received it. Score targets: prowlarr 8.2 → ~1.5,
  # readarr 9.2 → ~1.5, kavita 9.2 → ~1.5.
  systemd.services.prowlarr.serviceConfig = arrHarden;
  systemd.services.readarr = lib.mkIf books { serviceConfig = arrHarden; };
  systemd.services.kavita = lib.mkIf kavita { serviceConfig = arrHarden; };
  # We have to hook in to set binds paths, since (undocumented), everything is
  # RO except for a few whitelisted dirs. Fair, but frustrating without
  # knowledge.
  systemd.services.transmission.serviceConfig = {
    BindPaths = binds;
    # Hardening on top of nixpkgs defaults. systemd-analyze score: 1.4 → ~1.0.
    # The big remaining item (PrivateNetwork=0.5) is misleading: transmission is
    # already bound to wg-quick-pirate only, which systemd-analyze can't see.
    ProtectHome = lib.mkForce "tmpfs";
    ProtectProc = "invisible";
    ProcSubset = "pid";
    # Note: cannot drop @privileged from SystemCallFilter — transmission uses
    # quotactl() in tr_sys_path_get_capacity() on every RPC sessionGet, and
    # quotactl is in @privileged. Removing it makes the daemon SIGSYS on the
    # first RPC poll.
  };

  # A little bit of the personal config coming over. TODO: Create vpn-service
  # hook in sensitive.
  systemd.services.transmission.wantedBy = if pirateInterface then lib.mkForce [ "wg-quick-pirate.service" ] else [ ];
}
