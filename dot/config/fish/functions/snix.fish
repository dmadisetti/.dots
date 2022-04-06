function snix
  pushd $DOTFILES;
  mv ~/.xmonad/xmonad-x86_64-linux ~/.xmonad/xmonad-x86_64-linux.old 2> /dev/null;
  if test (count $argv) -eq 0
    sudo nixos-rebuild switch \
      --override-input sensitive \
      $DOTFILES/nix/sensitive \
      -j auto --flake ".#"
  else
    sudo nixos-rebuild $argv[1..-1] -j auto --flake ".#"
  end
  popd;
end

complete -f -c snix -a 'build test boot switch'
