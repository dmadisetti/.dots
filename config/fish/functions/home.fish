set DOTFILES ~/.dots
function home
  pushd $DOTFILES;
  unlock
  if test (count $argv) -eq 0
    home-manager switch --flake ".#$USER" -j auto
  else
    home-manager $argv[1..-1] -j auto
  end
  popd;
end
