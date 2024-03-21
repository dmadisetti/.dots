# 🤖🏠
{ extraComponents ? [ ]
, customComponents ? [ ]
, customModules ? [ ]
}:
{ lib, pkgs, config, ... }:
let
  cfg = config.services.home-assistant;
in
{
  # idk, we need to think about HACs projects too
  services.home-assistant = {
    enable = true;
    inherit customComponents;
    customLovelaceModules = customModules;

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

      pyvizio
      aiohomekit

      # homekit_controller
      # python_otbr_api
      # dacite

      opower
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
    };
  };
}
