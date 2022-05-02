#!/usr/bin/env bash
if [ -z "$DOTFILES" ]; then
   DOTFILES=$HOME/.dots
fi
SKIP_GENERATE=false
TMP=$(mktemp -d -t dots-flake-XXXXXXXXXX)
if [ -d $DOTFILES ]; then
  mkdir -p $DOTFILES/nix/sensitive/ 2> /dev/null \
    && TMP=$DOTFILES/nix/sensitive/
  if [ -f $DOTFILES/nix/spoof/flake.nix ]; then
    TEMPLATE=$DOTFILES/nix/spoof/flake.nix
  fi
  if [ -f $DOTFILES/nix/sensitive/flake.nix ]; then
    SKIP_GENERATE=true
  fi
fi

if [ "$SKIP_GENERATE" = false ]; then
  dots-manager template $TEMPLATE $TMP/flake.nix \
    <(echo "{\"sshd\": {\"enable\": false}}") || exit 1
fi

nix build --out-link $out \
  --override-input sensitive $TMP \
  --extra-experimental-features nix-command \
  --extra-experimental-features flakes \
  --no-write-lock-file -j auto "$SELF#_live" || exit 1

cp $out/result $out/live.iso
echo "Congrats! Flash $out/live.iso to your device of choice."
