# Common Nix
{ config, pkgs, ... }:

{
  imports = [ ];
  environment.pathsToLink = [ "/libexec" ]; # links /libexec from derivations to /run/current-system/sw
  services.xserver.enable = true;
  services.xserver.libinput.enable = true;
  services.xserver.displayManager.startx.enable = true;
}
