# User packages beyond DE

{ pkgs, lib, home, ... }:

{
  imports = [ ];

  home.packages = with pkgs; [
    zathura # pdfs
    zotero # research

    # isn't tweag the best
    ormolu
  ];
}

