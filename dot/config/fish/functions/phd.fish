function phd --wraps='cd /home/dylan/phd'
  _home ~/phd $argv
end

complete -f -c phd -a '(_complete ~/phd)'
