# Home sweet home 🏠

{ inputs, pkgs, stateVersion, ... }:

{
  imports = [
    ../programs/gpg.nix
  ] ++ (if inputs.sensitive.lib ? cachix then [
    inputs.declarative-cachix.homeManagerModules.declarative-cachix
    (import ../programs/cachix.nix { inherit pkgs; cache = inputs.sensitive.lib.cachix; })
  ] else [ ]);

  home.packages = with pkgs; [
    # security
    keybase
    wireguard-tools

    # all ya really need
    neofetch
    python38Packages.pynvim
    tmux

    # cool little extensions
    any-nix-shell
  ];

  programs = {
    neovim = {
      enable = true;
      viAlias = true;
      vimAlias = true;
      # builtins.readFile ../../../dot/vimrc;
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
        set DOTFILES ${inputs.sensitive.lib.dots}
        if not test -d $DOTFILES
          cp -R ${../../../.} $DOTFILES;
          chmod -R u+rw $DOTFILES;
        end
        # prefer the local link
        if test -f ~/.config/fish/user.fish
          source ~/.config/fish/user.fish
        else
          source $DOTFILES/dot/config/fish/config.fish;
        end
      '';
    };
    git = {
      enable = inputs.sensitive.lib.git.enable;
      extraConfig = {
        user = {
          name = inputs.sensitive.lib.git.name;
          email = inputs.sensitive.lib.git.email;
          signingKey = inputs.sensitive.lib.git.signing.key;
        };
        commit = {
          gpgSign = inputs.sensitive.lib.git.signing.enable;
        };
      };
      includes = [{ path = "${inputs.sensitive.lib.dots}/dot/gitconfig"; }];
    };
  };

  services = {
    keybase.enable = inputs.sensitive.lib.keybase.enable;
    kbfs = {
      enable = inputs.sensitive.lib.keybase.enable;
      mountPoint = "keybase";
    };
  };

  # Make sure flakes work by default..
  home.file.nixConf.text = ''
    experimental-features = nix-command flakes
  '';
  home.stateVersion = stateVersion;
}
