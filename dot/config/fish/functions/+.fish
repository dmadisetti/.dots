function get-pkgs
  echo "$history[1]" | cut -f1 -d' ' | xargs command-not-found 2>&1 >/dev/null | tail -n +3 | grep -oP "(?<=-p ).*\$"
end

function +
  set -l split (contains -i -- -- $argv)
  set -l continued 0
  if test -z "$split"
    set split (contains -i -- + $argv)
    set continued 1
  end

  if test -n "$split"
    set pkgs $argv[1..(math $split - 1)]
    set split (math $split + 1)
  else
    set pkgs $argv[1..-1]
  end
  if test (count $argv) -eq 0
    set pkgs (get-pkgs | head -1)
  end
  if test -n "$split"
    if test $continued -eq 1
      # nix shell --impure "nixpkgs#$pkgs" --command $pkgs[1] $argv[$split..-1]
      nix-shell -p $pkgs --command "$pkgs[1] $argv[$split..-1]"
    else
      # nix shell --impure "nixpkgs#$pkgs" --command $argv[$split..-1]
      nix-shell -p $pkgs --command "$argv[$split..-1]"
    end
  else
    # echo nix shell "nixpkgs#$pkgs"
    # nix shell --impure nixpkgs#$pkgs
    nix-shell -p $pkgs
  end
end

complete -f -c + -a "(get-pkgs)"
