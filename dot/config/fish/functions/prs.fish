function prs
  set -l gh (+ gh -- which gh)
  set -l query

  if test -z $argv[1]
    # If no label is provided, list all PRs without filtering by label
    echo "Right"
    set query "(.[] | .url)"
    echo $query
  else
    # If a label is provided, filter PRs by that label
    set -l label $argv[1]
    set query "(.[] | select(.labels[] | .name == \"$label\") | .url)"
  end
  echo $argv[1]
  echo $query
  for url in ($gh pr list --author "" --json url,labels -q $query)
    echo $url
    git apply --3way (curl -sL $url.diff | psub);
  end
end
