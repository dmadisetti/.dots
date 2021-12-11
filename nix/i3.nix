# Tell it how it is

{ pkgs, inputs, home, system, ... }:

{
  imports = [ ];

  xsession.windowManager.i3.package = pkgs.i3-gaps;
  xsession.windowManager.i3 = {
    enable = true;
    extraConfig = builtins.readFile ../i3/config;
  };

  home.packages = with pkgs; [
    kitty
    firefox
    playerctl
    feh
    compton
    xinit
  ];

  home.file.".xinitrc".source = ../i3/xinitrc;
}
