set -U fish_greeting ""

mkdir -p bin
set PATH /home/$USER/bin $PATH

export TEXINPUTS=".:~/.tex/lib:"
alias vim=nvim
alias vi=nvim

export EDITOR=vim
export CC=clang-10
