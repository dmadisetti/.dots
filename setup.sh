#!/bin/bash

setup() {
  local scriptpath="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

  rm -f ~/.vimrc ~/.config/nvim/init.vim ~/.vim/ulties
  mkdir -p ~/.vim

  ln -s $scriptpath/vimrc ~/.vimrc
  ln -s $scriptpath/vimrc ~/.config/nvim/init.vim
  ln -s $scriptpath/ulties ~/.vim/ulties
}

setup
