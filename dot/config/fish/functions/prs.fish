function prs
  set -l gh (+ gh -- which gh)
  set -l query

  if test -z $argv[1]
    # If no label is provided, list all PRs without filtering by label
    set query "(.[] | .url)"
  else
    # If a label is provided, filter PRs by that label
    set -l label $argv[1]
    set query "(.[] | select(.labels[] | .name == \"$label\") | .url)"
  end
  for url in ($gh pr list --author "" --json url,labels -q $query)
      set temp_diff (mktemp)
      curl -sL $url.diff > $temp_diff
      if not git apply --3way --check $temp_diff
          echo "Skipping $url due to merge conflicts"
          continue
      end
      git apply --3way $temp_diff
      rm $temp_diff
  end
end
