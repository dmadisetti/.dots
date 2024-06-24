function get-pkgs
  echo "$history[1]" | cut -f1 -d' ' | xargs command-not-found 2>&1 >/dev/null | tail -n +3 | grep -oP "(?<=-p ).*\$"
end

function add_language_packages
  set -l ecosystem $argv[1] # e.g., 'python3.8' or 'nodePackages_latest'
  set -l suffix $argv[2] # e.g., 'python3.8' or 'nodePackages_latest'
  set -l pkg_list (string split ',' $argv[3])
  set -l direct_shell $argv[4]
  set -l formatted_packages

  if test $direct_shell -eq 1
    # For nix-shell, format packages for withPackages for Python or directly for Node.js
    echo "\"$ecosystem.withPackages(ps: with ps; [ $pkg_list ])\""
  else
    # For nix shell, format packages with nixpkgs# prefix
    echo --expr
    echo "'with builtins.getFlake \"nixpkgs\"; with legacyPackages.x86_64-linux; \
      $ecosystem.withPackages (ps: with ps; [ $pkg_list ])'"
  end
end

function +
  set -l packages
  set -l extra_packages
  set -l command
  set -l direct_shell 0
  set -l command_mode 0 # 0: None, 1: --, 2: +
  set -l pkgs "nixpkgs"

  if test (count $argv) -eq 0
    set packages $packages (get-pkgs | head -1)
  end

  for arg in $argv
    switch $arg
      case '-x'
        set direct_shell 1
      case '--'
        set command_mode 1
        set command
      case '+'
        set command_mode 2
        set command
      case '--pkgs*'
        set pkgs (string replace -r -- '--pkgs=(.*)' '$1' $arg)
      case '--py*'
        set -l python_version (string replace -r -- '--py(\w+)=.*' '$1' $arg)
        set -l python_pkgs (string replace -r -- '--py\w+=(.*)' '$1' $arg)
        set extra_packages $extra_packages \
          (add_language_packages "python$python_version" "Packages" $python_pkgs $direct_shell)
      case '--node*'
        set -l node_suffix (string replace -r -- '--node(\w+)=.*' '$1' $arg)
        set -l node_pkgs (string replace -r -- '--node\w+=(.*)' '$1' $arg)
        set extra_packages $extra_packages \
          (add_language_packages "nodePackages" "$node_suffix" $node_pkgs $direct_shell)
      case '*'
        if test $command_mode -ne 0
          set command $command $arg
        else
          set packages $packages $arg
        end
    end
  end

  # Command execution logic (as previously detailed)
  set -l nix_cmd
  if test $direct_shell -eq 1
    set nix_cmd "nix-shell -p $packages $extra_packages"
  else
    set formatted_packages "$pkgs#"(string join " $pkgs#" $packages)
    set nix_cmd "nix shell --impure $formatted_packages $extra_packages"
  end

  switch $command_mode
    case 1 # Explicit command with --
      eval $nix_cmd --command $command
    case 2 # Implicit command with +
      eval $nix_cmd --command $packages[1] $command
    case '*' # No command specified
      eval $nix_cmd
  end
end

function _+__autocomplete
  set -l cmdline (commandline -p)
  set -l cmd (commandline -ct)
  set -l pattern $cmd
  set -l prefix ""
  set -l db_path "/nix/var/nix/profiles/per-user/root/channels/nixos/programs.sqlite"

  if string match -qr -- ' -- ' $cmdline || string match -qr -- ' + ' $cmdline
    return
  end

  # Check for package mode
  # TODO: Could clean this up a bit, but works as is.
  if string match -qr -- '--py.*=' $cmd
    set -l python_version (string replace -r -- '--py(\w+)=.*' '$1' $cmd)
    set -l pkgs (string replace -r -- '--py\w+=(.*)' '$1' $cmd)
    set pkgs (string split ',' $pkgs)
    set pattern python"$python_version"Packages.$pkgs[-1]
    set pkgs[-1] ""
    set prefix --py$python_version=(string join ',' $pkgs)
  # Check for Node package mode
  else if string match -qr -- '--node.*=' $cmd
    set -l node_suffix (string replace -r -- '--node(\w*)=.*' '$1' $arg)
    set -l pkgs (string replace -r -- '--node\w*=(.*)' '$1' $cmd)
    set pkgs (string split ',' $pkgs)
    set pattern nodePackages"$node_suffix".$pkgs[-1]
    set pkgs[-1] ""
    set prefix --node$node_suffix=(string join ',' $pkgs)
  end

  # Query the SQLite database and output package names
  if test -n "$pattern"
    sqlite3 "file:$db_path?immutable=1" \
      "SELECT DISTINCT package FROM Programs WHERE package LIKE '$pattern%'" \
      | while read -l package
      echo $prefix(echo $package | sed -e 's/^[^\.]*\.//')
    end
  end
end

complete -c + -a '(_+__autocomplete)' -f
