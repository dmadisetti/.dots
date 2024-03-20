function update
    pushd $DOTFILES
    set -l jq (+ jq -- which jq)
    set -l new (curl -sL "https://monitoring.nixos.org/prometheus/api/v1/query?query=channel_revision" | $jq -r ".data.result[] | select(.metric.channel==\"nixos-unstable\") | .metric.revision")
    set -l old ($jq -r ".nodes.nixpkgs.locked.rev" flake.lock)
    sed -i s/$old/$new/ flake.nix
    echo "$old vs $new"

    echo "Updating flakes with release versions"
    jq -r '.nodes | .[] | select(.original.ref != null) | .original.ref + " " + .original.repo + " " + .locked.owner + "/" + .original.repo' flake.lock | while read -l line
        set -l parts (string split " " -- $line)
        set -l ref $parts[1]
        set -l name $parts[2]
        set -l repo $parts[3]
        set -l updated (curl -s https://api.github.com/repos/$repo/releases/latest | jq -r .tag_name)

        if [ "$ref" != "$updated" ]
            echo "Updating $repo to $updated from $ref"
            echo sed -i "s|$repo\/$ref|$repo\/$updated|" flake.nix
            sed -i "s|$repo\/$ref|$repo\/$updated|" flake.nix
            unlock $name
        else
            echo "Skipping $repo"
        end
    end

    unlock nixpkgs
    unlock nixos-hardware
    unlock home-manager
    nix flake update

    unlock
    unlock dots-manager
    popd
end
