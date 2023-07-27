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
    # Capture output of git apply in a variable
    set apply_output (git apply --3way --verbose (cat $temp_diff | psub) 2>&1)
    rm $temp_diff
    # Split apply_output into lines
    set apply_output_lines (string split '\n' $apply_output)
    # Iterate over each line in apply_output
    for line in $apply_output_lines
      # If line contains 'with conflicts', run the sed command on the file mentioned
      if string match -r -q "Applied patch to '.*' with conflicts." $line
        # Extract the file name from the line
        set filename (string replace -r "Applied patch to '(.*?)' with conflicts." '$1' $line)
        echo "Resolving conflict in $filename for $url"
        # Run the sed command on the file
        sed -i -e '/<<<<<<< ours/,/>>>>>>> theirs/{/=======/,/>>>>>>> theirs/d}' -e '/<<<<<<< ours/d' $filename
      end
    end
  end
end
