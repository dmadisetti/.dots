#!/usr/bin/env bash
ensure_dotfiles

if [ ! -f "$DOTFILES"/nix/sensitive/flake.nix ]; then
  echo -en "$WELCOME"
  echo
  dots-manager template "$SPOOF" \
     "$DOTFILES"/nix/sensitive/flake.nix \
     <(echo -n "{\"user\": \"${nix_user:-$USER}\", \
               \"dots\": \"$DOTFILES\", \
               $(infer_settings), \
               \"default_wm\":\"none\"}") || exit 1
fi

set_sensitive

NIX_CONFIG="experimental-features = nix-command flakes" \
home-manager switch \
  --show-trace \
  --override-input sensitive \
  "$DOTFILES"/nix/sensitive \
  --flake "$DOTFILES#${nix_user:-$USER}" -j auto
