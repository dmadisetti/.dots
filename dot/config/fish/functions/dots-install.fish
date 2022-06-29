function dots-install
  pushd $DOTFILES;
  if test (count $argv) -eq 0
    if test ! -z "$LIVE"
      unlock
      unlock dots-manager
      sudo -E nix run \
        -j auto ".#install"
    else
      echo "You risk damaging your system. Set LIVE=1 to override."
    end
  end
  popd;
end

complete -f -c dots-install -a 'force'
