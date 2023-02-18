# 🏴 + 🦜= 💰
{ config, pkgs, lib, sensitive, ... }:
let
  pirateInterface = config.networking.wg-quick.interfaces ? pirate;
  interface =
    if pirateInterface then rec {
      endpoint = (lib.last config.networking.wg-quick.interfaces.pirate.address);
      ipv6 = "";
      ipv4 =  builtins.elemAt (lib.splitString "/" endpoint) 0;
    } else { };
in
{
  environment.systemPackages = with pkgs; [ mediainfo ];
  services = {
    plex = {
      enable = true;
      openFirewall = true;
      dataDir = "/media/plex";
    };
    sonarr = {
      enable = true;
      openFirewall = true;
      group = "plex";
    };
    radarr = {
      enable = true;
      openFirewall = true;
      group = "plex";
    };

    transmission = {
      enable = true;
      settings = {
        download-dir = "/media/downloads/unsorted";
        incomplete-dir = "/media/downloads/processing";
        incomplete-dir-enabled = true;
        rpc-whitelist = "127.0.0.1,192.168.*.*,10.13.37.*,10.1.1.*";
        # Change listening ip
        # rpc-bind-address = lib.mkForce interface.ipv4;
        bind-address-ipv4 = lib.mkForce interface.ipv4;
        bind-address-ipv6 = lib.mkForce interface.ipv6;
      };
    };
  };
  systemd.services.plex.serviceConfig.KillSignal = lib.mkForce "SIGKILL";

  # A little bit of the personal config coming over. TODO: Create vpn-service
  # hook in sensitive.
  systemd.services.transmission.wantedBy = if pirateInterface then lib.mkForce [ "wg-quick-pirate.service" ] else [ ];
}
