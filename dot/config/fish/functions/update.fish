function update
    pushd $DOTFILES
    set -l new (+ jq -- curl -s "https://monitoring.nixos.org/prometheus/api/v1/query?query=channel_revision" \| jq -r "'.data.result[] | select(.metric.channel==\"nixos-unstable\") | .metric.revision'")
    set -l old (+ jq -- jq -r ".nodes.nixpkgs.locked.rev" flake.lock)
    sed -i s/$old/$new/ flake.nix

    unlock nixpkgs
    unlock nixos-hardware
    unlock home-manager
    nix flake update

    unlock
    unlock dots-manager
    popd
end
