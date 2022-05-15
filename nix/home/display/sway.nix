# Tell it how it is
{ pkgs, home, ... }: {
  imports = [ ];

  wayland.windowManager.sway = {
    enable = true;
    extraConfig = builtins.readFile ../../../dot/config/i3/sway.config;
    # Zero out default config because nix is annoyingly paternalistic.
    config = rec {
      bars = [ ];
      keybindings = { };
    };
    wrapperFeatures.gtk = true;
  };

  home.packages = with pkgs; [ swaylock swayidle waybar wl-clipboard ];
}
