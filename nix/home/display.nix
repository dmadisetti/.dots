# All I need is a browser and a shell 🐌

{ pkgs, nixosConfig, ...}:
let
  # This doesn't work.. But we should make it?
  browser = (if (nixosConfig.services.tor.enable) then
    pkgs.tor-browser-bundle-bin else pkgs.firefox);
in
{
  imports = [ ];
  home.packages = [
    pkgs.kitty
    browser
  ];

  # Come sway or not, we all love polybar
  services = {
    polybar = {
      enable = true;
      config = ../../dot/config/polybar/config.ini;
      script = "polybar bar &";
    };
  };
}
