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
    set -l listing .nodes.root.inputs.\"$inputs\"
    set -l input .nodes.\"$inputs\"
    set -l compressed (jq -c "del($input) | del($listing)" flake.lock)
    if test -f flake.lock
        if test $status -eq 0
            if test -n "$compressed"
                echo "$compressed" | jq > flake.lock
            else
                echo "Error: output is empty" 1>&2
            end
        else
            echo "Error processing flake.lock with jq" 1>&2
        end
    end
    popd
end
