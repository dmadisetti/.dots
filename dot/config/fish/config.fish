set -U fish_greeting ""

mkdir -p ~/bin
set PATH /home/$USER/bin $PATH

alias icat="kitty +kitten icat"

alias vim=nvim
alias vi=nvim

export TEXINPUTS=".:~/.tex/lib:"
export EDITOR=vim

set -q DOTFILES; or set DOTFILES ~/.dots
if not test -e ~/.dots-installed
    $DOTFILES/setup.sh
end

# Check if we are on a multiuser system
test (stat -c '%G' /nix/store) != $USER && export NIX_REMOTE=daemon

# Set up system for live disk
if test -n "$LIVE" && ! test -d ~/keybase/private/$KEYBASE_USER
  if test -e /iso/paper.key.asc
    cat /iso/paper.key.asc | \
      gpg -ida --cipher-algo twofish 2> /dev/null | \
      xargs -i \
        keybase oneshot -u $KEYBASE_USER --paperkey "{}"
  else if test -e /iso/paper.key
    cat /iso/paper.key | \
      xargs -i \
        keybase oneshot -u $KEYBASE_USER --paperkey "{}"
  else
    echo "No paper key found..."
  end
end

if test -d ~/keybase/private/$KEYBASE_USER && ! test -d ~/.ssh
  mkdir -p ~/.ssh
  git clone keybase://private/$KEYBASE_USER/keys.git ~/.ssh/keys
  ln -s ~/.ssh/keys/config ~/.ssh/config
  chmod 600 ~/.ssh/keys/*
end

# Conditionally run if nix is installed
type --quiet "fenv" && fenv source  ~/.nix-profile/etc/profile.d/nix.sh
if not test -z (which any-nix-shell)
  any-nix-shell fish --info-right | source
end
