# Boxxeee <3
{ pkgs, home, ... }: {

  home.packages = with pkgs; [ openbox ];

  home.file.".xinitrc".source = ../../../dot/config/openbox/xinitrc;
}
