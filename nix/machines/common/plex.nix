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
in
{
  environment.systemPackages = with pkgs; [ mediainfo ];

  # Set group on the services to allow for file movement
  users.users.transmission.extraGroups = [ "plex" "sonarr" "radarr" ];

  # Testing. Is it transmission that does the moving?
  users.users.sonarr.extraGroups = [ "plex" "transmission" ];
  users.users.radarr.extraGroups = [ "plex" "transmission" ];

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
    prowlarr = {
      enable = true;
      openFirewall = true;
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
        announce-ip = lib.mkForce interface.announced;
        announce-ip-enabled = true;
      };
    };
  };
  systemd.services.plex.serviceConfig.KillSignal = lib.mkForce "SIGKILL";
  # We have to hook in to set binds paths, since (undocumented), everything is
  # RO except for a few whitelisted dirs. Fair, but frustrating without
  # knowledge.
  systemd.services.transmission.serviceConfig.BindPaths = [
    "/media/downloads/shows"
    "/media/downloads/movies"
  ];

  # A little bit of the personal config coming over. TODO: Create vpn-service
  # hook in sensitive.
  systemd.services.transmission.wantedBy = if pirateInterface then lib.mkForce [ "wg-quick-pirate.service" ] else [ ];
}
