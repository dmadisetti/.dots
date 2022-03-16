function get-pkgs
  echo "$history[1]" | cut -f1 -d' ' | xargs command-not-found 2>&1 >/dev/null | tail -n +3 | grep -oP "(?<=-p ).*\$"
end

function +
  set pkgs $argv[1..-1]
  if test (count $argv) -eq 0
    set pkgs (get-pkgs | head -1)
  end
  nix-shell -p $pkgs
end

complete -f -c + -a "(get-pkgs)"
