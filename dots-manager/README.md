# dots manager

missing:
 - actually setting up the submodules

 - manage machines
   - allow edit blocks

 - remove machines

- a manager to install new machines
  install computer
   - set up partitions
   - nixos-generate-config --dir whereever
   - customize
   - move over files
   - nixos-install --flake
   - sign off, suggest reboot

  install live     # booo partition hell
   - set up partitions
   - customize
   - build
   - dd

  install wsl
   - customize

  home-manager
   - customize
`nix-rebuild switch --flake ".#blahblah#$hostname"`

