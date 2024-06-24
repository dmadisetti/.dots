function daily
    cd ~/notes
    set -l daily (date "+daily/%Y/%B")
    set daily (echo $daily | tr '[:upper:]' '[:lower:]')
    set -l journal "$daily/$(date "+%d").md"

    if not test -e "$journal"
        mkdir -p $daily
         + zk + new --template=daily.md -g daily $daily
    else
        + zk + edit $journal
    end
end
