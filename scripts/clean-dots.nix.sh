#!/usr/bin/env bash
shopt -s extglob

set -e
dots-manager clean $FLAKE > flake.nix;
set +e

rm dot/backgrounds/!("live.png"|"grub.jpg"|"default.jpg") 2> /dev/null
rm nix/machines/!("gce.nix"|"momento.nix"|"wsl.nix") 2> /dev/null
rm nix/machines/hardware/!(".gitkeep") 2> /dev/null
rm nix/home/users/!($FLAKE_USER.nix) 2> /dev/null
mv nix/home/users/$FLAKE_USER.nix nix/home/users/user.nix

# unlock
echo -en "$(jq -r 'del(.nodes.root.inputs.sensitive) | del(.nodes.sensitive)' flake.lock)" > flake.lock
echo -en "$(jq -r 'del(.nodes.root.inputs."dots-manager") | del(.nodes."dots-manager")' flake.lock)" > flake.lock
