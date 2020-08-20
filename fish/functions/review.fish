function review
  PHD=/opt/phd/notes
  cd $PHD/reviews;
  if test (count $argv) -eq 0
    return;
  end

  set -l core (echo $argv[1] | sed 's/\.[^.]*$//' | sed 's/^.*\///')

  set -l file $argv[1]
  set -l review $PHD/reviews/$core.md
  if test ! -f $file
    cd -;
    echo "File does not exist."
    return 0
  end

  if test ! -f $review
    cp review.template $review
  end

  vim $review
  cd -
  jhu
  ./generate.py >> /dev/null
  cd -
end

complete -f -c review -a '(__fish_complete_path "$PHD/literature/")'
