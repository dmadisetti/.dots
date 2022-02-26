#!/usr/bin/env bash

setup() {
  local scriptpath="$(
    cd "$(dirname "$0")" > /dev/null 2>&1
    pwd -P
  )"
  local configpath="$scriptpath/config"
  local isnixos=$(uname -a | grep -iq nixos && echo 1 || echo 0)

  rm -rf ~/.vimrc ~/.config/nvim/user.vim ~/.config/nvim/ulties ~/.vim/ulties \
    ~/.vim/config ~/.config/fish ~/.config/i3 ~/.config/kitty ~/.config/yapf \
    ~/.gitconfig ~/.tmux.conf ~/.dots-installed

  mkdir -p ~/.zotero/data
  mkdir -p ~/.config/nvim
  mkdir -p ~/.vim

  # nvim
  ln -s $scriptpath/dot/vimrc ~/.vimrc
  ln -s $scriptpath/dot/vim/ulties ~/.config/nvim/ulties
  ln -s $scriptpath/dot/vim/ulties ~/.vim/ulties
  ln -s $scriptpath/dot/vim ~/.vim/config
  # if managed by nixos, then we just import our script.
  test $isnixos -eq 1 && {
    ln -s $scriptpath/dot/vimrc ~/.config/nvim/user.vim
  } || {
    rm -rf ~/.config/nvim/init.vim
    ln -s $scriptpath/dot/vimrc ~/.config/nvim/init.vim
  }

  # fish
  mkdir ~/.config/fish/
  # if managed by nixos, be careful with fish_variables since must be writeable.
  test $isnixos -eq 1 && {
    ln -s $configpath/fish/functions ~/.config/fish/
    ln -s $configpath/fish/config.fish ~/.config/fish/user.fish
    cp $configpath/fish/fish_variables ~/.config/fish/
    chmod +w ~/.config/fish/fish_variables
  } || {
    ln -s $configpath/fish/* ~/.config/fish/
  }

  # i3
  ln -s $configpath/i3 ~/.config

  # kitty
  ln -s $configpath/kitty ~/.config

  # git
  ln -s $scriptpath/dot/gitconfig ~/.gitconfig

  # tmux
  ln -s $scriptpath/dot/tmux/tmux.conf ~/.tmux.conf

  # yapf
  ln -s $configpath/yapf ~/.config/yapf

  # bashrc as backup
  test -n ${BASH} && test -z ${DOTFILES_LOADED+x} && {
    echo "[ -f ~/.dots/dot/bashrc ] && . ~/.dots/dot/bashrc" >> ~/.bashrc
  }

  # indicate we have run the installation
  touch ~/.dots-installed
}

setup
