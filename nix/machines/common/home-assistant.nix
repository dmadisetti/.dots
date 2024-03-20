# 🤖🏠
{ extraComponents ? [ ]
, disks ? [ ]
, custom-components ? { }
, config-files ? { }
, static-content ? "custom_components"
}:
{ lib, pkgs, config, ... }:
let
  cfg = config.services.home-assistant;

  # Shamelessly stolen from graham33/nur-packages
  # Ideally strip once NixOS/nixpkgs#160346 is in.
  linkCommand = config-path: file: ''
    rm -rf ${cfg.configDir}/${config-path} && ln -s ${file} ${cfg.configDir}/${config-path}
  '';
  customComponentFiles = lib.mapAttrs' (k: v: (lib.nameValuePair "custom_components/${k}" "${v}/custom_components/${k}")) custom-components;
  configFilesPreStart = lib.concatStrings (lib.mapAttrsToList linkCommand config-files);
  customComponentsPreStart = lib.optionalString (custom-components != { }) (''
    # custom components
    mkdir -p ${cfg.configDir}/custom_components
    touch ${cfg.configDir}/custom_components/__init__.py
  '' + lib.concatStrings (lib.mapAttrsToList linkCommand customComponentFiles));
  staticContentPreStart = lib.optionalString (static-content != null) ''
    # static content
    rm -rf ${cfg.configDir}/www && ${pkgs.rsync}/bin/rsync -rltDL --include '*/' \
      --include '*.js*' \
      --include '*.html' \
      --include '*.css' \
      --include '*.jpg' \
      --include '*.png' \
      --include '*.gif' \
      --exclude '*' \
      ${cfg.configDir}/${static-content}/ ${cfg.configDir}/www
    chmod -R o+w  ${cfg.configDir}/www
  '';

  wrap_disk = disk: {
    type = "disk_use";
    arg = disk;
  };
in
{
  # idk, we need to think about HACs projects too
  systemd.services.home-assistant.preStart = configFilesPreStart + customComponentsPreStart + staticContentPreStart;
  services.home-assistant = {
    enable = true;
    extraComponents = [
      # Components required to complete the onboarding
      "esphome"
      "met"
      "radio_browser"

      "systemmonitor"
    ] ++ extraComponents;
    extraPackages = python3Packages: with python3Packages; [
      # recorder postgresql support
      pyatv
      gtts
      ibeacon-ble
      getmac

      pychromecast

      rokuecp

      # govee-api-laggat
      pyvizio
      aiohomekit
      python_otbr_api
      dacite

      opower

      # govee-hacs
      pexpect
    ];
    config = {
      # Includes dependencies for a basic setup
      # https://www.home-assistant.io/integrations/default_config/
      default_config = { };
      http = {
        server_host = [ "127.0.0.1" "10.1.1.246"];
        server_port = 8123;
      };
      # If you wanted to explicitly define a dashboard.
      # lovelace = {
      #   mode = "yaml";
      #   resources = [{
      #     type = "module";
      #     url = "/local/transmission-card/transmission-card.js";
      #   }];
      # };

      # See https://www.home-assistant.io/integrations/systemmonitor
      sensor = [
        {
          platform = "systemmonitor";
          resources = [
            {
              type = "memory_use_percent";
            }
            {
              type = "processor_use";
            }
            {
              type = "last_boot";
            }
          ] ++ (map wrap_disk disks);
        }
      ];
    };
  };
}
