set -U fish_greeting ""

mkdir -p ~/bin
set PATH /home/$USER/bin $PATH

alias icat="kitty +kitten icat"

export TEXINPUTS=".:~/.tex/lib:"
alias vim=nvim
alias vi=nvim

export EDITOR=vim
export CC=clang-12

if not test -e ~/.dots-installed
    ~/.dots/setup.sh
end

# Set up system for live disk
if test -n "$LIVE" && ! test -d ~/keybase/private/$KEYBASE_USER
  cat /iso/paper.gpg | \
    gpg -id 2> /dev/null | \
    xargs -i \
      keybase oneshot -u $KEYBASE_USER --paperkey "{}"
end

if test -d ~/keybase/private/$KEYBASE_USER && ! test -d ~/.ssh
  mkdir -p ~/.ssh
  git clone keybase://private/$KEYBASE_USER/keys.git ~/.ssh/keys
  ln -s ~/.ssh/keys/config ~/.ssh/config
end

any-nix-shell fish --info-right | source
