# Tell it how it is

{ pkgs, home, ... }:

{
  imports = [ ];

  home.packages = with pkgs; [
    fbterm
    fbv
    browsh
  ];

  home.file.".fbtermrc".source = ../../fbtermrc;

  home.sessionVariables = {
   FBTERM_BACKGROUND_IMAGE = 1;
  };
}
