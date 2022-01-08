# Home sweet home

{ pkgs, inputs, system, ... }:

{
  imports = [
    ./gpg.nix
  ];

  home.packages = with pkgs; [
    gnupg
    keybase
    wireguard

    neofetch
    python38Packages.pynvim
    tmux
  ];

  programs = {
    neovim = {
      enable = true;
      viAlias = true;
      vimAlias = true;
      extraConfig = builtins.readFile ../../dot/vimrc;
    };
  };

  services = {
    keybase.enable = true;
    kbfs = {
      enable = true;
      mountPoint = "keybase";
    };
  };

  home.stateVersion = "21.11";
}
