function problems
    cd ~/notes/problems
    # Example: zk new --template=problem.md -g problems --title="Bayesian Lagrange" --extra "tags=math-research-bayes"
    set -l title $argv[1]
    set -l safe_title (echo $title | tr '[:upper:]' '[:lower:]' | sed 's/ /-/g')
    # convert commas to hyphens
    set -l tags (echo $argv[2] | sed 's/,/-/g')

    if not test -e "$title"
         + zk + new --template=problem.md -g problem --title=\"$title\" --extra \"tags=$tags\" --extra "safe=$safe_title"
    else
        + zk + edit $safe_title
    end
end
