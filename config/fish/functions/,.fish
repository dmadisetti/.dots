function get-pkgs
  echo "$history[1]" | cut -f1 -d' ' | xargs command-not-found 2>&1 >/dev/null | tail -n +3 | grep -oP "(?<=-p ).*\$"
end

function ,
  set pkg $argv[1]
  set command $history[1]
  if test (count $argv) -eq 0
    set pkg (get-pkgs | head -1)
  else if test (count $argv) -gt 1
    set command $argv[1..-1]
  end
  echo $pkg
  echo $command
  echo nix-shell -p $pkg --command "$command"
  nix-shell -p $pkg --command "$command"
end

complete -f -c , -a "(get-pkgs)"
