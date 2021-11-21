# Home sweet home

{ pkgs, inputs, system, ... }:

{
  imports = [ ];

  home.packages = with pkgs; [
    ncurses
    python38Packages.pynvim
    tmux
  ];

  programs = {
    neovim = {
      enable = true;
      viAlias = true;
      vimAlias = true;
      extraConfig = builtins.readFile ../vimrc;
    };
  };
}

