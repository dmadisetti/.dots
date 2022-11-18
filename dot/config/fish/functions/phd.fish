function phd --wraps='cd ~/phd'
  _home ~/phd $argv
end

complete -f -c phd -a '(_complete ~/phd)'
