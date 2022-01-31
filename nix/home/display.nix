# All I need is a browser and a shell 🐌

{ pkgs, config, ... }:
let
  # This doesn't work.. But we should make it?
  browser = (if (config.services ? tor) then
    pkgs.tor-browser-bundle-bin else pkgs.firefox);
in
{
  imports = [ ];
  home.packages = [
    pkgs.kitty
    browser
  ];
}
