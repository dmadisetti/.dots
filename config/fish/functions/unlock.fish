set DOTFILES ~/.dots
function unlock
  pushd $DOTFILES;
  set -l listing ".nodes.root.inputs.sensitive"
  set -l input ".nodes.sensitive"
  set -l compressed \'(+ jq -- jq -c "\"del($input) | del($listing)\"" flake.lock)\'
  test -f flake.lock && \
    + jq -- echo "$compressed" \| jq > flake.lock;
  popd;
end
