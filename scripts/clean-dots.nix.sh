#!/usr/bin/env bash
shopt -s extglob

rm dot/backgrounds/!("live.png"|"grub.jpg"|"default.jpg") 2> /dev/null
rm nix/machines/!("momento.nix") 2> /dev/null
rm nix/machines/hardware/!(".gitkeep") 2> /dev/null
mv nix/home/users/$FLAKE_USER.nix nix/home/users/user.nix

dots-manager clean $FLAKE > flake.nix;

# unlock
echo -en "$(jq -r 'del(.nodes.root.inputs.sensitive) | del(.nodes.sensitive)' flake.lock)" > flake.lock
echo -en "$(jq -r 'del(.nodes.root.inputs."dots-manager") | del(.nodes."dots-manager")' flake.lock)" > flake.lock
