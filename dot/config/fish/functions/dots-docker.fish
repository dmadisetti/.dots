function dots-docker
  pushd $DOTFILES;
  nix build \
    --override-input sensitive \
    $DOTFILES/nix/sensitive \
    -j auto ".#docker";
  command -v docker > /dev/null && docker image load -i result;
  popd;
end
