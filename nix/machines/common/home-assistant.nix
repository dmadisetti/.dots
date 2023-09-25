# 🤖🏠
{ extraComponents ? [ ]
, disks ? [ ]
, custom-components ? { }
, config-files ? { }
, static-content ? { }
}:
{ lib, ... }:
let
  cfg = config.services.home-assistant;

  # Shamelessly stolen from graham33/nur-packages
  # Ideally strip once NixOS/nixpkgs#160346 is in.
  linkCommand = config-path: file: ''
    rm -f ${cfg.configDir}/${config-path} && ln -s ${file} ${cfg.configDir}/${config-path}
  '';
  customComponentFiles = lib.mapAttrs' (k: v: (nameValuePair "custom_components/${k}" "${v}/custom_components/${k}")) custom-components;
  configFilesPreStart = lib.concatStrings (lib.mapAttrsToList linkCommand config-files);
  customComponentsPreStart = lib.optionalString (custom-components != { }) (''
    # custom components
    mkdir -p ${cfg.configDir}/custom_components
  '' + lib.concatStrings (lib.mapAttrsToList linkCommand customComponentFiles));
  staticContentPreStart = lib.optionalString (static-content != null) ''
    # static content
    rm -f ${cfg.configDir}/www && ln -s ${static-content} ${cfg.configDir}/www
  '';

  wrap_disk = disk: {
    type = "disk_use";
    arg = disk;
  };
in
{
  # idk, we need to think about HACs projects too
  services.home-assistant = {
    enable = true;
    preStart = configFilesPreStart + customComponentsPreStart + staticContentPreStart;
    extraComponents = [
      # Components required to complete the onboarding
      "esphome"
      "met"
      "radio_browser"

      "systemmonitor"
    ] ++ builtins.trace extraComponents extraComponents;
    extraPackages = python3Packages: with python3Packages; [
      # recorder postgresql support
      pyatv
      gtts
      ibeacon-ble
      getmac
    ];
    config = {
      # Includes dependencies for a basic setup
      # https://www.home-assistant.io/integrations/default_config/
      default_config = { };
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
