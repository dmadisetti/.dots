#!/usr/bin/env bash

setup() {
  local scriptpath="$(
    cd "$(dirname "$0")" > /dev/null 2>&1
    pwd -P
  )"
  local configpath="$scriptpath/config"

  rm -rf ~/.vimrc ~/.config/nvim/init.vim ~/.config/nvim/ulties ~/.vim/ulties \
    ~/.vim/config ~/.config/fish ~/.config/i3 ~/.config/kitty ~/.config/yapf \
    ~/.gitconfig ~/.tmux.conf

  mkdir -p ~/.config/nvim
  mkdir -p ~/.vim

  # nvim
  ln -s $scriptpath/vimrc ~/.vimrc
  ln -s $scriptpath/vimrc ~/.config/nvim/init.vim
  ln -s $scriptpath/vim/ulties ~/.config/nvim/ulties
  ln -s $scriptpath/vim/ulties ~/.vim/ulties
  ln -s $scriptpath/vim ~/.vim/config

  # fish
  ln -s $configpath/fish ~/.config

  # i3
  ln -s $configpath/i3 ~/.config

  # kitty
  ln -s $configpath/kitty ~/.config

  # git
  ln -s $scriptpath/gitconfig ~/.gitconfig

  # tmux
  ln -s $scriptpath/tmux/tmux.conf ~/.tmux.conf

  # yapf
  ln -s $configpath/yapf ~/.config/yapf

  # bashrc as backup
  test -n ${BASH} && test -z ${DOTFILES_LOADED+x} && {
    echo "[ -f ~/.dotfiles/bashrc ] && . ~/.dotfiles/bashrc" >> ~/.bashrc
  }
}

setup
