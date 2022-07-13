function _complete
    set saved_pwd $PWD
    builtin cd $DOTFILES
    and PWD=$DOTFILES complete -C"cd $arg"
    builtin cd $saved_pwd
end

function d --wraps='cd /home/dylan/.dots'
  if test (count $argv) -eq 0
    cd /home/dylan/.dots
  else
    cd /home/dylan/.dots/$argv
  end
end

complete -f -c d  -a '(_complete)'
