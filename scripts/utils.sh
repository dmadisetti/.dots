#!/usr/bin/env bash
infer_settings() {
  local EXTRA=""
  EXTRA="\"keybase\":{"
  if [ -n "$KEYBASE_USER" ]; then
    local PAPER="$(echo $(cat /iso/paper* || echo '') | tr -d \n)"
    EXTRA="$EXTRA\"enable\":true"
    EXTRA="$EXTRA, \"keybase_username\":\"$KEYBASE_USER\""
    EXTRA="$EXTRA, \"keybase_paper\":\"$PAPER\""
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
  # if not nixos, we do not need to provide system settings
  uname -a | grep -iq nixos || echo ",\
      \"hashed\":\"\", \
      \"networking\":\"{}\"";
}

ensure_dotfiles() {
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
}

set_sensitive() {
  if [ ! -d "$DOTFILES"/nix/sensitive/.git ]; then
    pushd "$DOTFILES"/nix/sensitive > /dev/null || exit 1
    git init . > /dev/null || :
    git add -N flake.nix
    git add -N nix/home/users/user.nix 2> /dev/null || :
    git add -N nix/home/users/${nix_user:-$USER}.nix 2> /dev/null || :
    popd > /dev/null || exit 1
  fi
}
