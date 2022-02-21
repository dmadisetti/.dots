# Home sweet home 🏠

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

    any-nix-shell
  ];

  programs = {
    neovim = {
      enable = true;
      viAlias = true;
      vimAlias = true;
      # builtins.readFile ../../dot/vimrc;
      # in theory by but actually set by setup.sh, and we symink so it's
      # editable.
      extraConfig = ''
          source ~/.config/nvim/user.vim
      '';
      withNodeJs = true;

      # python is true by default, but we need pybtex for managing citations.
      # see https://github.com/NixOS/nixpkgs/blob/master/pkgs/top-level/python-packages.nix
      extraPython3Packages = (py: with py; [ pybtex ]);
    };
  };

  services = {
    keybase.enable = true;
    kbfs = {
      enable = true;
      mountPoint = "keybase";
    };
  };

  # Setting fish config will bootstrap other dots
  home.file.".config/fish/config.fish".source = ../../config/fish/config.fish;

  home.stateVersion = "22.05";
}
