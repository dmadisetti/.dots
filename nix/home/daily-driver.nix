# User packages beyond DE
{ pkgs, home, ... }: {
  imports = [ ];

  home.packages = with pkgs; [
    jq # of course
    ripgrep # gotta go fast

    ormolu # isn't tweag the best
  ];
}
