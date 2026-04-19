# Systemd services for the KSP streaming stack
#
# Service chain:
#   cowboy-ksp-xvfb  →  cowboy-ksp  →  cowboy-ksp-stream
#                                    →  cowboy-ksp-marimo
{ config, lib, pkgs, ... }:

let
  cfg = config.services.cowboy.ksp;
  enabledAgents = lib.filterAttrs (_: a: a.enable) config.services.cowboy.agents;
  n = "cowboy";

  encoderFlags = {
    nvenc = "-c:v h264_nvenc -preset ${cfg.stream.preset} -b:v ${cfg.stream.bitrate} -maxrate ${cfg.stream.bitrate} -bufsize ${cfg.stream.bitrate}";
    x264 = "-c:v libx264 -preset ${cfg.stream.preset} -b:v ${cfg.stream.bitrate} -maxrate ${cfg.stream.bitrate} -bufsize ${cfg.stream.bitrate}";
  };

  krpcPkg = pkgs.callPackage ./krpc.nix {};
  krpcPython = pkgs.python3.withPackages (ps: [
    krpcPkg
    ps.matplotlib
  ]);
in
{
  config = lib.mkIf (enabledAgents != {} && cfg.enable) {
    # Xvfb virtual display
    systemd.services."${n}-ksp-xvfb" = {
      description = "Xvfb virtual display for KSP";
      partOf = [ "${n}.target" ];
      wantedBy = [ "${n}.target" ];

      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.xorg.xorgserver}/bin/Xvfb ${cfg.display.number} -screen 0 ${cfg.display.resolution}x24 -ac +extension GLX +render -noreset";
        Restart = "on-failure";
        RestartSec = 2;
      };
    };

    # Setup: bind mount KSP to /tmp for faster I/O
    systemd.services."${n}-ksp-setup" = {
      description = "Setup KSP in /tmp";
      after = [ "${n}-ksp-ckan.service" ];
      wants = [ "${n}-ksp-ckan.service" ];
      before = [ "${n}-ksp.service" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = pkgs.writeShellScript "${n}-ksp-setup" ''
          set -e
          mkdir -p /tmp/ksp
          # Create bind mount from gameDir to /tmp/ksp if not already mounted
          if ! mountpoint -q /tmp/ksp; then
            mount --bind "${cfg.gameDir}" /tmp/ksp
          fi
        '';
        ExecStop = pkgs.writeShellScript "${n}-ksp-cleanup" ''
          if mountpoint -q /tmp/ksp; then
            umount /tmp/ksp || true
          fi
          rm -rf /tmp/ksp
        '';
      };
    };
    # KSP game process
    systemd.services."${n}-ksp" = {
      description = "Kerbal Space Program (headless, kRPC enabled)";
      after = [ "${n}-ksp-xvfb.service" "${n}-ksp-ckan.service" "${n}-ksp-setup.service" ];
      requires = [ "${n}-ksp-xvfb.service" "${n}-ksp-setup.service" ];
      wants = [ "${n}-ksp-ckan.service" ];
      partOf = [ "${n}.target" ];
      wantedBy = [ "${n}.target" ];

      environment.DISPLAY = cfg.display.number;

      serviceConfig = {
        Type = "simple";
        ExecStart = "/tmp/ksp/${cfg.binary}";
        WorkingDirectory = "/tmp/ksp";
        Restart = "on-failure";
        RestartSec = 10;
        TimeoutStartSec = 120;
        MemoryMax = "8G";
      };
    };

    # ffmpeg stream to Twitch
    systemd.services."${n}-ksp-stream" = lib.mkIf cfg.stream.enable {
      description = "KSP Twitch stream (ffmpeg x11grab -> RTMP)";
      after = [ "${n}-ksp.service" ];
      requires = [ "${n}-ksp.service" "${n}-ksp-xvfb.service" ];
      partOf = [ "${n}.target" ];
      wantedBy = [ "${n}.target" ];

      serviceConfig = {
        Type = "simple";
        # Give KSP time to start rendering
        ExecStartPre = "${pkgs.coreutils}/bin/sleep 30";
        ExecStart = pkgs.writeShellScript "${n}-ksp-stream" ''
          STREAM_KEY=$(cat "${cfg.stream.twitchKeyFile}")
          exec ${pkgs.ffmpeg-full}/bin/ffmpeg \
            -f x11grab \
            -framerate ${toString cfg.stream.fps} \
            -video_size ${cfg.display.resolution} \
            -i ${cfg.display.number}+0,0 \
            ${encoderFlags.${cfg.stream.encoder}} \
            -pix_fmt yuv420p \
            -g ${toString (cfg.stream.fps * 2)} \
            -f flv \
            "${cfg.stream.rtmpUrl}/$STREAM_KEY"
        '';
        Restart = "on-failure";
        RestartSec = 5;
      };
    };

    # Marimo mission control notebook
    systemd.services."${n}-ksp-marimo" = lib.mkIf cfg.marimo.enable {
      description = "Marimo mission control notebook for KSP";
      after = [ "${n}-ksp.service" ];
      wants = [ "${n}-ksp.service" ];
      partOf = [ "${n}.target" ];
      wantedBy = [ "${n}.target" ];

      environment = {
        KRPC_HOST = "127.0.0.1";
        KRPC_PORT = toString cfg.krpc.port;
      };

      serviceConfig = {
        Type = "simple";
        ExecStart = ''
          ${pkgs.marimo}/bin/marimo run ${./notebook/mission_control.py} \
            --host 0.0.0.0 --port ${toString cfg.marimo.port} --headless
        '';
        Restart = "on-failure";
        RestartSec = 5;
      };
    };
  };
}
