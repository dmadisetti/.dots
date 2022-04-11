#!/usr/bin/env bash
if [ -z "$DOTFILES" ]; then
   DOTFILES=$HOME/.dots
fi
if [ ! -d $DOTFILES ]; then
  git clone $(cat $REMOTE) $DOTFILES || {
    echo "Could not clone .dots";
    exit 1;
  };
  cd $DOTFILES
  git checkout -B main
  mkdir -p $DOTFILES/nix/sensitive
  cd -
fi

if [ ! -f $DOTFILES/nix/sensitive/flake.nix ]; then
  dots-manager template $SPOOF \
     $DOTFILES/nix/sensitive/flake.nix \
     <(echo "{\"user\": \"$USER\", \
              \"hashed\":\"\", \
              \"networking\":\"{}\", \
              \"default_wm\":\"none\"}")
fi

home-manager switch \
  --override-input sensitive \
  $DOTFILES/nix/sensitive \
  --flake "$DOTFILES#$USER" -j auto
