# Tell it how it is
{ pkgs, home, ... }: {
  imports = [ ../programs/polybar.nix ];

  xsession.windowManager.i3.package = pkgs.i3-gaps;
  xsession.windowManager.i3 = {
    enable = true;
    extraConfig = builtins.readFile ../../../dot/config/i3/i3.config;
    # Zero out default config because nix is annoyingly paternalistic.
    config = rec {
      bars = [ ];
      keybindings = { };
    };
  };

  home.packages = with pkgs; [ picom feh playerctl ];

  home.file.".xinitrc".source = ../../../dot/config/i3/xinitrc;
}
