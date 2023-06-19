# Boxxeee <3
{ pkgs, home, ... }: {
  # imports = [ ../programs/polybar.nix ];

  # services.xserver.windowManager.openbox = {
  #   enable = true;
  #   # extraConfig = builtins.readFile ../../../dot/config/i3/i3.config;
  #   # Zero out default config because nix is annoyingly paternalistic.
  #   config = rec {
  #     bars = [ ];
  #     keybindings = { };
  #   };
  # };

  # home.packages = with pkgs; [ picom feh playerctl ];

  home.file.".xinitrc".source = ../../../dot/config/openbox/xinitrc;
}
