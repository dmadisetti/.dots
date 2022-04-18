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

infer_settings() {
  local EXTRA=""
  EXTRA="\"keybase\":{"
  if [ -n "$KEYBASE_USER" ]; then
    EXTRA="$EXTRA\"enable\":true"
    EXTRA="$EXTRA, \"keybase_username\":\"$KEYBASE_USER\""
    EXTRA="$EXTRA, \"keybase_paper\":\"$(cat /boot/paper* || echo '')\""
  fi
  EXTRA="$EXTRA}, \"git\": {\"enable\":true";
  GIT_USER="$(git config user.name)"
  if [ -n "$GIT_USER" ]; then
    EXTRA="$EXTRA, \"git_name\":\"$GIT_USER\""
  fi
  GIT_EMAIL="$(git config user.email)"
  if [ -n "$GIT_EMAIL" ]; then
    EXTRA="$EXTRA, \"git_email\":\"$GIT_EMAIL\""
  fi
  if "true" = "$(git config commit.gpgsign)"; then
    GIT_KEY="$(git config user.signingKey)"
    if [ -n "$GIT_KEY" ]; then
      EXTRA="$EXTRA, \"git_signing\":{"
      EXTRA="$EXTRA\"enable\":true"
      EXTRA="$EXTRA, \"git_signing_key\":\"$GIT_KEY\""
      EXTRA="$EXTRA}";
    fi
  fi
  EXTRA="$EXTRA}";
  echo $EXTRA
}

EXTRA="$(infer_settings)"
if [ ! -f $DOTFILES/nix/sensitive/flake.nix ]; then
  dots-manager template $SPOOF \
     $DOTFILES/nix/sensitive/flake.nix \
     <(echo "{\"user\": \"$USER\", \
              \"hashed\":\"\", \
              $EXTRA, \
              \"networking\":\"{}\", \
              \"default_wm\":\"none\"}")
fi

home-manager switch \
  --override-input sensitive \
  $DOTFILES/nix/sensitive \
  --show-trace \
  --flake "$DOTFILES#$USER" -j auto
