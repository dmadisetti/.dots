function unlock
    if test (count $argv) -eq 0
        set inputs sensitive
    else if test (count $argv) -eq 1
        set inputs $argv[1]
    else
        echo "invalid usage" 1>&2
        return 1
    end
    pushd $DOTFILES
    set -l listing ".nodes.root.inputs.\\\"$inputs\\\""
    set -l input ".nodes.\\\"$inputs\\\""
    set -l compressed \'(+ jq -- jq -c "\"del($input) | del($listing)\"" flake.lock)\'
    test -f flake.lock && + jq -- echo "$compressed" \| jq >flake.lock
    popd
end
