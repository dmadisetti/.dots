set DOTFILES ~/.dots
function live
  pushd $DOTFILES;
  if test (count $argv) -eq 0
    sudo nix build -j auto ".#_live"
  else
    sudo nix $argv[1..-1] -j auto ".#_live"
  end
  popd;
end

complete -f -c live -a 'build'
