# 🐡🐠🐟🦈
{ inputs, pkgs, ... }: {
  imports = [ ];
  programs.fish = {
    enable = true;
    shellInit = ''
      set DOTFILES ${inputs.sensitive.lib.dots}
      if set -q IS_GCE
        ln -sf ${../../../.} $DOTFILES;
      else if not test -d $DOTFILES
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
  home.packages = [
    pkgs.sqlite # for the `+` program. Makes life so sweet.
  ];
}
