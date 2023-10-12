function snix
  if test -n "$LIVE" && ! test -f ~/.dots-warned
    echo Be careful! A live disk may not have a \
    password or network settings properly provisioned. \
    Make sure you fill in these settings in $DOTFILES/nix/sensitive/flake.nix.\n\
    \* Run this command again to continue as normal.
    touch ~/.dots-warned
    return 1
  end

  pushd $DOTFILES;
  mv ~/.xmonad/xmonad-x86_64-linux ~/.xmonad/xmonad-x86_64-linux.old 2> /dev/null;
  if test (count $argv) -eq 0
    nixos-rebuild --use-remote-sudo switch \
      --override-input sensitive \
      $DOTFILES/nix/sensitive \
      -j auto --show-trace --flake ".#"
  else
    sudo nixos-rebuild $argv[1..-1] -j auto --flake ".#"
  end
  popd;
end

complete -f -c snix -a 'build test boot switch'
