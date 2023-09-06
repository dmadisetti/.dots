function nbg
  # Grep for notebooks using jq and some magic
  set -l raw "false"
  set -l git_commits 0

  set -l offset 1
  set -l deleted 0
  set args $argv
  for i in (seq (count $args))
    switch $argv[(math $i - $deleted)]
      case "--raw"
        set raw "true"
        set -e args[$offset]
        set -e argv[$(math $i - $deleted)]
        set deleted (math $deleted + 1)
        continue
      case "--git=*"
        set git_commits (echo $args[$offset] | cut -d'=' -f2)
        set -e args[$offset]
        set -e argv[$(math $i - $deleted)]
        set deleted (math $deleted + 1)
        continue
      case "--git"
        set -e args[$offset]
        set -e argv[$(math $i - $deleted)]
        set git_commits $args[$offset]
        set -e args[$offset]
        set -e argv[$(math $i - $deleted)]
        set deleted (math $deleted + 1)
        continue
      case "*"
        set -e args[1]
        set offset (math $offset + 1)
    end
  end

  if not set -q argv[1]
    echo "error: The following required arguments were not provided:"
    echo "    <PATTERN>"
    return 1
  end

  # If no file, glob, or directory provided, set a default
  set PATTERN $argv[1]
  set -e argv[1]
  set -l wild "false"
  if not set -q argv[1]
    set wild "true"
    set argv ./*.ipynb
  end
  set -l files $argv[1..-1]

  function search_file
    set PATTERN $argv[1]
    set raw $argv[2]
    set FILENAME $argv[3]
    set cell_num 0

    if test "$raw" = "true"
      set PATTERN (string escape -- $argv[1])
    end

    jq -r '.cells[] | select(.cell_type=="code") | .source | map(select(test("'"$PATTERN"'"))) | @text' $FILENAME | while read -l line
      set cell_num (math $cell_num + 1)
      if test "$raw" = "true"
        echo $line | rg --with-filename --line-number --color=always --fixed-strings $PATTERN | sed "s|^|Cell $cell_num in $FILENAME: |"
      else
        echo $line | rg --with-filename --line-number --color=always $PATTERN | sed "s|^|Cell $cell_num in $FILENAME: |"
      end
    end
  end

  function perform_search
    set -l PATTERN $argv[1]
    set -l raw_flag $argv[2]
    set -l files $argv[3..-1]
    for item in $files
      if test -d $item
        set -l dir_files $item/*.ipynb
        for file in $dir_files
          search_file $PATTERN $raw_flag $file
        end
      else
        search_file $PATTERN $raw_flag $item
      end
    end
  end

  if test $git_commits -gt 0
    set -l current_branch (git symbolic-ref --short HEAD)
    set -l commits (git log --pretty=format:"%h" -n $git_commits)

    for commit in $commits
      git -c advice.detachedHead=false checkout $commit
      if test "$wild" = "true"
        set files ./*.ipynb
      end
      perform_search $PATTERN $raw $files
    end

    git checkout $current_branch
    echo "Search complete."
    return
  end

  perform_search $PATTERN $raw $files
end

complete -c nbg -a '(__fish_complete_suffix ".ipynb")'
