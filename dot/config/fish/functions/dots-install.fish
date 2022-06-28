function dots-install
  pushd $DOTFILES;
  if test (count $argv) -eq 0
    if test ! -z "$LIVE"
      nix run \
        --override-input sensitive \
        $DOTFILES/nix/sensitive \
        -j auto ".#install"
    end
  end
  popd;
end

complete -f -c dots-install -a 'force'
