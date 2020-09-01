{ pkgs ? import <nixpkgs> {}
}:
pkgs.mkShell {
  name = "dev-shell";
  buildInputs = [
    pkgs.fish
    pkgs.tmux
    pkgs.ncurses
    pkgs.git
    pkgs.python38Packages.pynvim
    pkgs.neovim
  ];
  shellHook = ''
    ./setup.sh
  '';
}
