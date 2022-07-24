# 🖖im
{ home, pkgs, ... }: {
  imports = [ ];

  home.packages = with pkgs; [ python38Packages.pynvim ];

  programs.neovim = {
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
    extraPython3Packages = py: with py; [ pybtex ];
  };
}
