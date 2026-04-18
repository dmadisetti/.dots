# CKAN mod management for KSP
# Oneshot service that installs mods before KSP starts (same pattern as cowboy-ollama-pull)
{ config, lib, pkgs, ... }:

let
  cfg = config.services.cowboy.ksp;
  enabledAgents = lib.filterAttrs (_: a: a.enable) config.services.cowboy.agents;
  n = "cowboy";

  # kRPC settings.cfg to enable auto-start without in-game interaction
  krpcSettings = pkgs.writeText "krpc-settings.cfg" ''
    rpc_port = ${toString cfg.krpc.port}
    stream_port = ${toString cfg.krpc.streamPort}
    auto_start_server = True
    auto_accept_connections = True
    address = 0.0.0.0
  '';
in
{
  config = lib.mkIf (enabledAgents != {} && cfg.enable) {
    systemd.services."${n}-ksp-ckan" = {
      description = "Install KSP mods via CKAN";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = pkgs.writeShellScript "${n}-ksp-ckan-install" ''
          set -euo pipefail
          export PATH="${lib.makeBinPath [ pkgs.ckan pkgs.mono ]}:$PATH"
          GAMEDIR="${cfg.gameDir}"

          # Register KSP instance if not present
          if ! ckan instance list 2>/dev/null | grep -q "mun"; then
            ckan instance add mun "$GAMEDIR" --headless 2>/dev/null || true
          fi
          ckan instance default mun 2>/dev/null || true

          # Install each mod (idempotent)
          ${lib.concatMapStringsSep "\n" (mod: ''
            if ! ckan list --instance mun 2>/dev/null | grep -qi "${mod}"; then
              echo "Installing: ${mod}"
              ckan install --instance mun --headless --no-recommends "${mod}" || \
                echo "WARNING: failed to install ${mod}"
            else
              echo "Already installed: ${mod}"
            fi
          '') cfg.mods}

          # Write kRPC auto-start config
          KRPC_DIR="$GAMEDIR/GameData/kRPC/PluginData"
          mkdir -p "$KRPC_DIR"
          cp "${krpcSettings}" "$KRPC_DIR/settings.cfg"
          echo "kRPC configured: port=${toString cfg.krpc.port}, auto_start=true"
        '';
      };
    };
  };
}
