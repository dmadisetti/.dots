# User packages beyond DE
{ pkgs, home, ... }: {
  imports = [ ];

  home.packages = with pkgs; [
    jq # of course
    fd # pretty standard
    ripgrep # gotta go fast

    ormolu # isn't tweag the best
  ];
}
