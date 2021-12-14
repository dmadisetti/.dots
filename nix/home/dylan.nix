# Home sweet home

{ pkgs, inputs, system, ... }:

{
  imports = [ ];

  home.packages = with pkgs; [
    keybase
    neofetch
    python38Packages.pynvim
    tmux
  ];

  programs = {
    neovim = {
      enable = true;
      viAlias = true;
      vimAlias = true;
      extraConfig = builtins.readFile ../../vimrc;
    };
  };

  services = {
    keybase.enable = true;
    kbfs = {
      enable = true;
      mountPoint = "keybase";
    };
  };

  home.stateVersion = "21.05";
}
