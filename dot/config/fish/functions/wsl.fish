function wsl
  pushd $DOTFILES;
  if test (count $argv) -eq 0
    nix build \
      --override-input sensitive \
      $DOTFILES/nix/sensitive \
      -j auto ".#_wsl"
  else
    nix $argv[1..-1] -j auto ".#_wsl"
  end
  popd;
end

complete -f -c wsl -a 'build'
