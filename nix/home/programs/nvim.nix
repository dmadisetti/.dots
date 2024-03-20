# 🖖im
{ home, pkgs, ... }: {
  imports = [ ];

  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    # builtins.readFile ../../../dot/vimrc;
    # in theory by but actually set by setup.sh, and we symink so it's
    # editable.
    plugins = [ ];
    extraConfig = ''
      source ~/.config/nvim/user.vim
      hi LspDiagnosticsVirtualTextError guifg=red gui=bold,italic,underline
      hi LspDiagnosticsVirtualTextWarning guifg=orange gui=bold,italic,underline
      hi LspDiagnosticsVirtualTextInformation guifg=yellow gui=bold,italic,underline
      hi LspDiagnosticsVirtualTextHint guifg=green gui=bold,italic,underline
    '';
    withNodeJs = true;

    # python is true by default, but we need pybtex for managing citations.
    # see https://github.com/NixOS/nixpkgs/blob/master/pkgs/top-level/python-packages.nix
    extraPython3Packages = py: with py; [ pybtex ];
  };
}
