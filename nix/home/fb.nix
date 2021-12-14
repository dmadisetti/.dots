# Tell it how it is

{ pkgs, home, ... }:

{
  imports = [ ];

  home.packages = with pkgs; [
    fbterm
    fbv
  ];

  home.sessionVariables = {
   FBTERM_BACKGROUND_IMAGE = 1;
  };
}
