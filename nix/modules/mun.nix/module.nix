# mun.nix — KSP agent control + Twitch streaming for cowboy
#
# Import this module alongside cowboy's nixosModules.default:
#   imports = [ cowboy.nixosModules.default ./mun.nix/module.nix ];
#
# Then enable:
#   services.cowboy.ksp.enable = true;
#   services.cowboy.ksp.gameDir = "/opt/ksp";
#   services.cowboy.ksp.stream.twitchKeyFile = "/run/agenix/twitch-stream-key";
{ config, lib, pkgs, ... }:

let
  cfg = config.services.cowboy;
  ksp = cfg.ksp;
  enabledAgents = lib.filterAttrs (_: a: a.enable) cfg.agents;

  krpcPkg = pkgs.callPackage ./krpc.nix {};
  krpcPython = pkgs.python3.withPackages (ps: [
    krpcPkg
    ps.matplotlib
  ]);
in
{
  imports = [
    ./services.nix
    ./ckan.nix
  ];

  options.services.cowboy.ksp = {
    enable = lib.mkEnableOption "KSP + Twitch streaming stack";

    gameDir = lib.mkOption {
      type = lib.types.path;
      description = "Path to Kerbal Space Program installation directory";
      example = "/home/dylan/.steam/steam/steamapps/common/Kerbal Space Program";
    };

    binary = lib.mkOption {
      type = lib.types.str;
      default = "KSP.x86_64";
      description = "Name of the KSP executable within gameDir";
    };

    mods = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "kRPC" ];
      description = "CKAN mod identifiers to install declaratively";
    };

    krpc = {
      port = lib.mkOption {
        type = lib.types.port;
        default = 50000;
        description = "kRPC RPC server port";
      };

      streamPort = lib.mkOption {
        type = lib.types.port;
        default = 50001;
        description = "kRPC stream server port";
      };
    };

    display = {
      number = lib.mkOption {
        type = lib.types.str;
        default = ":99";
        description = "X display number for Xvfb";
      };

      resolution = lib.mkOption {
        type = lib.types.str;
        default = "1920x1080";
        description = "Virtual display resolution";
      };
    };

    stream = {
      enable = lib.mkEnableOption "Twitch RTMP streaming";

      twitchKeyFile = lib.mkOption {
        type = lib.types.str;
        default = "/run/agenix/twitch-stream-key";
        description = "Path to agenix-managed file containing the Twitch stream key";
      };

      rtmpUrl = lib.mkOption {
        type = lib.types.str;
        default = "rtmp://live.twitch.tv/app";
        description = "Twitch RTMP ingest URL";
      };

      encoder = lib.mkOption {
        type = lib.types.enum [ "nvenc" "x264" ];
        default = "nvenc";
        description = "Video encoder — nvenc for NVIDIA GPU, x264 for CPU fallback";
      };

      bitrate = lib.mkOption {
        type = lib.types.str;
        default = "4500k";
        description = "Video bitrate";
      };

      preset = lib.mkOption {
        type = lib.types.str;
        default = "p4";
        description = "NVENC preset (p1=fastest, p7=best quality) or x264 preset";
      };

      fps = lib.mkOption {
        type = lib.types.int;
        default = 30;
        description = "Capture framerate";
      };
    };

    marimo = {
      enable = lib.mkEnableOption "Marimo mission control notebook";

      port = lib.mkOption {
        type = lib.types.port;
        default = 2718;
        description = "Port for the marimo notebook server";
      };
    };
  };

  config = lib.mkIf (enabledAgents != {} && ksp.enable) {
    # Register cowboy skills for KSP control
    services.cowboy.skills = {
      ksp-pilot = {
        description = "Control KSP vessels via kRPC Python API";
        requires = [ krpcPython ];
        additionalTools = [ "bash" "read" "write" ];
        prompt = ./skills/ksp-pilot.md;
        tags = [ "ksp" "control" "krpc" ];
      };

      mission-plan = {
        description = "Plan orbital maneuvers, transfers, and mission profiles";
        requires = [ krpcPython ];
        additionalTools = [ "bash" "read" ];
        prompt = ./skills/mission-plan.md;
        tags = [ "ksp" "orbital-mechanics" "planning" ];
      };
    };

    # Add kRPC python + marimo to agent home environments
    home-manager.users = lib.mapAttrs' (_: acfg:
      lib.nameValuePair acfg.user {
        home.packages = [ krpcPython ]
          ++ lib.optional ksp.marimo.enable pkgs.marimo;
      }
    ) enabledAgents;
  };
}
