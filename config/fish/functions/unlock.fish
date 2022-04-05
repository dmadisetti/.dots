function unlock
  pushd $DOTFILES;
  set -l listing .nodes.root.inputs.sensitive
  set -l input .nodes.sensitive
  test -f flake.lock && \
    echo \
      (jq -c "del($input) | del($listing)" flake.lock) | \
      jq > flake.lock 2> /dev/null;
  popd;
end
