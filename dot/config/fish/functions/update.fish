function update
    pushd $DOTFILES
    set -l new (git ls-remote github:NixOs/nixpkgs refs/heads/master | cut -f1)
    set -l old (+ jq -- jq ".nodes.nixpkgs.locked.rev" flake.lock | tr -d '"')
    sed -i s/$old/$new/ flake.nix
    unlock nixpkgs
    nix flake update
    unlock
    unlock dots-manager
    popd
end
