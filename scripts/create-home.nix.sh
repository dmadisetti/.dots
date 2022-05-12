#!/usr/bin/env bash
infer_settings() {
  local EXTRA=""
  EXTRA="\"keybase\":{"
  if [ -n "$KEYBASE_USER" ]; then
    EXTRA="$EXTRA\"enable\":true"
    EXTRA="$EXTRA, \"keybase_username\":\"$KEYBASE_USER\""
    EXTRA="$EXTRA, \"keybase_paper\":\"$(cat /boot/paper* || echo '')\""
  fi
  EXTRA="$EXTRA}";
  GIT_USER="$(git config user.name)"
  if [ -n "$GIT_USER" ]; then
    EXTRA="$EXTRA, \"git\": {\"enable\":true";
    EXTRA="$EXTRA, \"git_name\":\"$GIT_USER\""
    GIT_EMAIL="$(git config user.email)"
    if [ -n "$GIT_EMAIL" ]; then
      EXTRA="$EXTRA, \"git_email\":\"$GIT_EMAIL\""
    fi
    if [ "true" = "$(git config commit.gpgsign)" ]; then
      GIT_KEY="$(git config user.signingKey)"
      if [ -n "$GIT_KEY" ]; then
        EXTRA="$EXTRA, \"git_signing\":{"
        EXTRA="$EXTRA\"enable\":true"
        EXTRA="$EXTRA, \"git_signing_key\":\"$GIT_KEY\""
        EXTRA="$EXTRA}";
      fi
    fi
    EXTRA="$EXTRA}";
  fi
  echo "$EXTRA"
}

if [ -z "$DOTFILES" ]; then
   DOTFILES="$HOME/.dots"
fi
if [ ! -d "$DOTFILES" ]; then
  git clone "$(cat "$REMOTE")" "$DOTFILES" || {
    echo "Could not clone .dots";
    exit 1;
  };
  pushd "$DOTFILES" || exit 1
  git checkout -B main
  popd || exit 1
fi
if [ ! -d "$DOTFILES"/nix/sensitive ]; then
  mkdir -p "$DOTFILES"/nix/sensitive
fi
if [ ! -f "$DOTFILES"/nix/sensitive/flake.nix ]; then
  dots-manager template "$SPOOF" \
     "$DOTFILES"/nix/sensitive/flake.nix \
     <(echo "{\"user\": \"$USER\", \
              \"hashed\":\"\", \
              \"dots\":\"$DOTFILES\", \
              $(infer_settings), \
              \"networking\":\"{}\", \
              \"default_wm\":\"none\"}")
fi
if [ ! -d "$DOTFILES"/nix/sensitive/.git ]; then
  pushd "$DOTFILES"/nix/sensitive || exit 1
  git init .
  git add .
  popd || exit 1
  git add .
fi

NIX_CONFIG="experimental-features = nix-command flakes" \
home-manager switch \
  --override-input sensitive \
  "$DOTFILES"/nix/sensitive \
  --no-write-lock-file \
  --flake "$DOTFILES#$USER" -j auto
