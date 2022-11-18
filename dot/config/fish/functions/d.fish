function d --wraps='cd $DOTFILES'
  _home $DOTFILES $argv
end

complete -f -c d  -a '(_complete $DOTFILES)'
