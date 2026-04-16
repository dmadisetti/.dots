# mun.nix

Stream KSP to Twitch, piloted by an AI agent via kRPC.

## Prerequisites

- NixOS with cowboy module enabled
- KSP 1 installed (Steam or manual)
- NVIDIA GPU (1660Ti or similar) for NVENC streaming
- Twitch stream key in agenix

## Setup

### 1. Add your Twitch stream key to agenix

In your secrets config (e.g. `sensitive/secrets.nix`):

```nix
"twitch-stream-key".publicKeys = [ your-age-key ];
```

Then encrypt it:

```bash
echo -n "live_xxxxxxxxxxxxxxxxxxxx" | agenix -e secrets/twitch-stream-key.age
```

Reference it in your NixOS config:

```nix
age.secrets.twitch-stream-key = {
  file = ./secrets/twitch-stream-key.age;
  mode = "0400";
};
```

### 2. Import the module

```nix
# configuration.nix or wherever your cowboy config lives
imports = [
  cowboy.nixosModules.default
  ./path/to/cowboy/mun.nix/module.nix
];
```

### 3. Configure

```nix
services.cowboy.ksp = {
  enable = true;
  gameDir = "/home/dylan/.steam/steam/steamapps/common/Kerbal Space Program";
  # binary = "KSP.x86_64";  # default

  stream = {
    enable = true;
    twitchKeyFile = config.age.secrets.twitch-stream-key.path;
    # encoder = "nvenc";     # default, swap to "x264" if no NVIDIA
    # bitrate = "4500k";     # default
    # fps = 30;              # default
  };

  marimo.enable = true;
  # marimo.port = 2718;      # default
};
```

### 4. Rebuild

```bash
sudo nixos-rebuild switch
```

## Starting it

Everything runs under `cowboy.target`. Start the whole stack:

```bash
sudo systemctl start cowboy.target
```

Or start services individually:

```bash
# Just KSP (starts Xvfb + CKAN automatically)
sudo systemctl start cowboy-ksp

# Stream comes up after KSP (30s delay for KSP to load)
sudo systemctl start cowboy-ksp-stream

# Mission control notebook
sudo systemctl start cowboy-ksp-marimo
```

## Checking status

```bash
# All services at a glance
systemctl status cowboy-ksp-xvfb cowboy-ksp-ckan cowboy-ksp cowboy-ksp-stream cowboy-ksp-marimo

# Logs
journalctl -u cowboy-ksp -f        # KSP output
journalctl -u cowboy-ksp-stream -f  # ffmpeg/stream
journalctl -u cowboy-ksp-ckan       # CKAN mod install (oneshot)
```

## Using it

### Mission control dashboard

Open http://localhost:2718 in a browser. The marimo notebook shows:

- Live telemetry (altitude, velocity, orbit)
- Fuel gauges
- Throttle slider, staging button, SAS mode selector
- 2D orbit plot

### Agent control

The cowboy agent gets two skills automatically:

- **ksp-pilot** — vessel control, telemetry, flight patterns
- **mission-plan** — orbital mechanics, transfer calculations

From the agent's workspace, or any kRPC-capable Python:

```python
import krpc
conn = krpc.connect(name='cowboy', address='127.0.0.1', rpc_port=50000)
vessel = conn.space_center.active_vessel
print(f"Flying: {vessel.name} at {vessel.flight().mean_altitude:.0f}m")
```

### Watching the stream

Go to your Twitch channel. The stream starts ~30 seconds after KSP finishes loading.

## Stopping it

```bash
sudo systemctl stop cowboy.target
```

## Troubleshooting

**CKAN fails to install kRPC**
Check `journalctl -u cowboy-ksp-ckan`. CKAN needs network access — make sure `network-online.target` is up. You can also install kRPC manually: drop the kRPC folder into `GameData/` in your KSP directory.

**Stream not appearing on Twitch**
Check `journalctl -u cowboy-ksp-stream`. Common issues:
- Stream key wrong — verify the agenix secret
- NVENC unavailable — switch `encoder = "x264"` as a fallback
- KSP hasn't started rendering — the 30s delay might not be enough on slow starts

**kRPC not connecting**
KSP needs to be fully loaded to a save game with a vessel. kRPC auto-starts (configured by the CKAN service), but it won't accept connections until a scene is loaded. Launch a vessel from the space center first.

**Black screen on stream**
Xvfb is running but KSP may not be rendering. Check `DISPLAY=:99 xdpyinfo` to verify the display is up, and `journalctl -u cowboy-ksp` for Unity/KSP errors.
