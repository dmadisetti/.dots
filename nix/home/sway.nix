# Tell it how it is

{ pkgs, inputs, home, system, ... }:

{
  imports = [ ];

  wayland.windowManager.sway = {
    enable = true;
    # extraConfig = builtins.readFile ../../configs/i3/config;
    # Zero out default config because nix is annoyingly paternalistic.
    config = rec {
      bars = [ ];
      keybindings = { };
    };
    wrapperFeatures.gtk = true;
  };

  home.packages = with pkgs; [
    swaylock
    swayidle
    waybar
    wl-clipboard
  ];
}
