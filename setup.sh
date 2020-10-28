#!/bin/bash

setup() {
  local scriptpath="$(
    cd "$(dirname "$0")" > /dev/null 2>&1
    pwd -P
  )"

  rm -rf ~/.vimrc ~/.config/nvim/init.vim ~/.config/nvim/ulties ~/.vim/ulties \
    ~/.vim/config ~/.config/fish ~/.config/i3 ~/.gitconfig ~/.tmux.conf

  mkdir -p ~/.config/nvim
  mkdir -p ~/.vim

  # nvim
  ln -s $scriptpath/vimrc ~/.vimrc
  ln -s $scriptpath/vimrc ~/.config/nvim/init.vim
  ln -s $scriptpath/ulties ~/.vim/ulties
  ln -s $scriptpath/ulties ~/.config/nvim/ulties
  ln -s $scriptpath/vim ~/.vim/config

  # fish
  ln -s $scriptpath/fish ~/.config

  # i3
  ln -s $scriptpath/i3 ~/.config

  # git
  ln -s $scriptpath/gitconfig ~/.gitconfig

  # tmux
  ln -s $scriptpath/tmux/tmux.conf ~/.tmux.conf

  # bashrc as backup
  echo "[ -f ~/.dotfiles/bashrc ] && . ~/.dotfiles/bashrc" >> ~/.bashrc
}

setup
