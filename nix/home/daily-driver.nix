# User packages beyond DE
{ pkgs, home, ... }:
{
  imports = [ ];

  home.packages = with pkgs; [
    jq # of course
    ripgrep # gotta go fast

    zathura # pdfs
    zotero # research

    ormolu # isn't tweag the best
  ];
}
