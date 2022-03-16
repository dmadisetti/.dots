# Home sweet home 🏠

{ pkgs, inputs, system, stateVersion, ... }:

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
    fish = {
      enable = true;
      shellInit = ''
        source ~/.dots/config/fish/config.fish;
      '';
    };
    git = {
      enable = inputs.sensitive.lib.git.enable;
      extraConfig = {
        user = {
          name = inputs.sensitive.lib.git.enable;
          email = inputs.sensitive.lib.git.enable;
          signingKey = inputs.sensitive.lib.git.signing.key;
        };
        commit = {
          gpgSign = inputs.sensitive.lib.git.signing.enable;
        };
      };
      includes = [{ path = "~/.dots/dot/gitconfig"; }];
    };
  };

  services = {
    keybase.enable = inputs.sensitive.lib.keybase.enable;
    kbfs = {
      enable = inputs.sensitive.lib.keybase.enable;
      mountPoint = "keybase";
    };
  };

  home.stateVersion = stateVersion;
}
