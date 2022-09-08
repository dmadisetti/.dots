set PHD ~/phd/notes
function review
  phd
  cd notes/
  if test (count $argv) -eq 0
    return;
  end

  set -l core (echo $argv[1] | sed 's/\.[^.]*$//' | sed 's/^.*\///')

  set -l file $argv[1]
  set -l review reviews/$core.md
  if test ! -f $file
    cd -;
    echo "File does not exist."
    return 0
  end

  if test ! -f $review
    cp reviews/review.template $review
  end
  vim $review
end

complete -f -c review -a '(__fish_complete_path "$PHD/literature/")'
