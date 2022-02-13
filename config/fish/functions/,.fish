function get-pkgs
  echo "$history[1]" | cut -f1 -d' ' | xargs command-not-found 2>&1 >/dev/null | tail -n +3 | grep -oP "(?<=-p ).*\$"
end

function ,
  set command $argv[1]
  if test (count $argv) -eq 0
    set command (get-pkgs | head -1)
  end
  nix-shell -p $command --command $history[1]
end

complete -f -c , -a "(get-pkgs)"
