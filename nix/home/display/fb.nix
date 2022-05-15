# Tell it how it is

{ pkgs, home, ... }:

{
  imports = [ ];

  home.packages = with pkgs; [ fbterm fbv fbida browsh ];

  home.file.".fbtermrc".source = ../../../dot/fbtermrc;

  home.sessionVariables = { FBTERM_BACKGROUND_IMAGE = 1; };
}
