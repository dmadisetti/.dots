set -U fish_greeting ""

mkdir -p ~/bin
set PATH /home/$USER/bin $PATH

alias icat="kitty +kitten icat"

alias vim=nvim
alias vi=nvim
alias vio "nvim -O"
alias dev=develop

export TEXINPUTS=".:~/.tex/lib:"
export EDITOR=vim

set -q DOTFILES; or set DOTFILES ~/.dots
if not test -e ~/.dots-installed
    $DOTFILES/setup.sh;
end
export DOTFILES

# Check if we are on a multiuser system
test (stat -c '%G' /nix/store) != $USER && export NIX_REMOTE=daemon

# Set up system for live disk
function _unlock
  if test -e $argv
    if string match -q -- "*.asc" $argv
      cat $argv | \
        gpg -ida --cipher-algo twofish 2> /dev/null | \
        xargs -i \
          keybase oneshot -u $KEYBASE_USER --paperkey "{}"
    else
      cat $argv | \
        xargs -i \
          keybase oneshot -u $KEYBASE_USER --paperkey "{}"
    end
    return $status
  end
  return 1
end
if test -n "$LIVE" && ! test -d ~/keybase/private/$KEYBASE_USER
  if _unlock $DOTFILES/nix/sensitive/paper.key.asc
  else if _unlock /iso/paper.key.asc
  else if _unlock $DOTFILES/nix/sensitive/paper.key.asc
  else if _unlock /iso/paper.key
  else
    echo "No paper key found..."
  end
end

# Set up ssh keys
if test -d ~/keybase/private/$KEYBASE_USER && ! test -d ~/.ssh
  mkdir -p ~/.ssh
  git clone keybase://private/$KEYBASE_USER/keys.git ~/.ssh/keys 2> /dev/null && begin
    ln -s ~/.ssh/keys/config ~/.ssh/config
    find ~/.ssh/keys -type f | xargs chmod 600
  end
end

# Conditionally run if nix is installed
set source ~/.nix-profile/etc/profile.d/nix.sh
type --quiet "fenv" && test -f $source && fenv source $source
if not test -z (which any-nix-shell)
  any-nix-shell fish --info-right | source
end
