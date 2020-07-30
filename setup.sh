#!/bin/bash

setup() {
  local scriptpath="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

  rm -rf ~/.vimrc ~/.config/nvim/init.vim ~/.vim/ulties ~/.vim/config \
        ~/.config/fish ~/.gitconfig

  mkdir -p ~/.config
  mkdir -p ~/.vim

  # nvim
  ln -s $scriptpath/vimrc ~/.vimrc
  ln -s $scriptpath/vimrc ~/.config/nvim/init.vim
  ln -s $scriptpath/ulties ~/.vim/ulties
  ln -s $scriptpath/vim ~/.vim/config

  # fish
  ln -s $scriptpath/fish ~/.config

  # git
  ln -s $scriptpath/gitconfig ~/.gitconfig
}

setup
