# Fancy grub and networking
{ config, pkgs, ... }: {
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
      };
    };
  };
}
