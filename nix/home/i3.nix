# Tell it how it is

{ pkgs, lib, home, ... }:

{
  imports = [ ];

  xsession.windowManager.i3.package = pkgs.i3-gaps;
  xsession.windowManager.i3 = {
    enable = true;
    extraConfig = builtins.readFile ../../config/i3/config.i3;
    # Zero out default config because nix is annoyingly paternalistic.
    config = rec {
      bars = [ ];
      keybindings = { };
    };
  };

  home.packages = with pkgs; [
    compton
    feh
    i3blocks
    i3status
    playerctl
  ];

  home.file.".xinitrc".source = ../../config/i3/xinitrc;
}
