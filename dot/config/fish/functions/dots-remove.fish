function dots-remove
    pushd $DOTFILES
    if test (count $argv) -eq 0
      set flake $DOTFILES/flake.nix
      nix run $DOTFILES/dots-manager -- remove $flake $flake 2> /tmp/flake-removed || return 1
      set removed (tail -1 /tmp/flake-removed)
      rm nix/machines/$removed.nix
      rm nix/machines/hardware/$removed.nix
    else if test (count $argv) -eq 1
      set flake $DOTFILES/flake.nix
      nix run $DOTFILES/dots-manager -- remove $flake $flake $argv[1] || return 1
      rm nix/machines/$argv[1].nix
      rm nix/machines/hardware/$argv[1].nix
    else if test (count $argv) -eq 3
      set flake $argv[1]
      nix run $DOTFILES/dots-manager -- remove $flake $flake $argv[2] || return 1
      rm nix/machines/$argv[2].nix
      rm nix/machines/hardware/$argv[2].nix
    else if test (count $argv) -eq 3
      nix run $DOTFILES/dots-manager -- remove $argv[1..-1] || return 1
      rm nix/machines/$argv[3].nix
      rm nix/machines/hardware/$argv[3].nix
    else
      nix run $DOTFILES/dots-manager -- remove --help
    end
    popd
end
