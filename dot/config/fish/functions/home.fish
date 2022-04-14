function home
  pushd $DOTFILES;
  unlock
  if test (count $argv) -eq 0
    nix run ".#home" -j auto
  else
    + home-manager -- home-manager "$argv[1..-1]" -j auto
  end
  popd;
end
