function live
  pushd $DOTFILES;
  if test (count $argv) -eq 0
    nix build \
      --override-input sensitive \
      $DOTFILES/nix/sensitive \
      -j auto ".#_live"
  else
    nix $argv[1..-1] -j auto ".#_live"
  end
  popd;
end

complete -f -c live -a 'build'
