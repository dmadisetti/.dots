set DOTFILES ~/.dots
function live
  pushd $DOTFILES;
  if test (count $argv) -eq 0
    sudo nix build -j auto ".#live"
  else
    sudo nix $argv[1..-1] -j auto ".#live"
  end
  popd;
end

complete -f -c live -a 'build'
