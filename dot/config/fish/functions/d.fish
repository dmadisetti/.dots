function d --wraps='cd /home/dylan/.dots'
  _home $DOTFILES $argv
  # if test (count $argv) -eq 0
  #   cd /home/dylan/.dots
  # else
  #   cd /home/dylan/.dots/$argv
  # end
end

complete -f -c d  -a '(_complete $DOTFILES)'
