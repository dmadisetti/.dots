# User packages beyond DE
{ pkgs, home, ... }: {
  imports = [ ];

  home.packages = with pkgs; [
    fd # pretty standard
    ripgrep # gotta go fast

    ormolu # isn't tweag the best
  ];
}
