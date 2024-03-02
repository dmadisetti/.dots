#!/usr/bin/env bash

# Managing symlinks over home-manager or nix means we can use this on all
# platforms :), also it means we don't end up with those terrible ro links.
# Why use GNU stow when I can use ln for the same amount of effort 🐂🐑?
setup() {
  local scriptpath="$(
    cd "$(dirname "$0")" > /dev/null 2>&1
    pwd -P
  )"
  local configpath="$scriptpath/dot/config"
  local isnixos=$(uname -a | grep -iq nixos && echo 1 || echo 0)
  local isnix=$(test -d ~/.nix-profile && echo 1 || echo 0)
  isnix=$(($isnix + $isnixos > 0 ? 1 : 0))

  rm -rf ~/.vimrc ~/.config/nvim/user.vim ~/.config/nvim/ulties ~/.vim/ulties \
    ~/.vim/config ~/.config/fish/functions ~/.config/i3 ~/.config/kitty ~/.config/yapf \
    ~/.gitconfig ~/.tmux.conf ~/.backgrounds ~/.config/compton.cfg ~/.config/eww \
    ~/.config/dunst ~/.config/rofi ~/.config/hypr ~/.config/openbox ~/.dots-installed

  mkdir -p ~/.config/fish
  mkdir -p ~/.zotero/data
  mkdir -p ~/.config/nvim
  mkdir -p ~/.vim

  # nvim
  ln -s $scriptpath/dot/vimrc ~/.vimrc
  ln -s $scriptpath/dot/vim/ulties ~/.config/nvim/ulties
  ln -s $scriptpath/dot/vim/ulties ~/.vim/ulties
  ln -s $scriptpath/dot/vim ~/.vim/config
  # if managed by nixos, then we just import our script.
  test $isnix -eq 1 && {
    ln -s $scriptpath/dot/vimrc ~/.config/nvim/user.vim
  } || {
    rm -rf ~/.config/nvim/init.vim
    ln -s $scriptpath/dot/vimrc ~/.config/nvim/init.vim
  }

  # fish
  # if managed by nixos, be careful with fish_variables since must be writeable.
  test $isnix -eq 1 && {
    ln -s $configpath/fish/functions ~/.config/fish/
    ln -sf $configpath/fish/config.fish ~/.config/fish/user.fish
    cp $configpath/fish/fish_variables ~/.config/fish/
    chmod +w ~/.config/fish/fish_variables

    # if we are using nix but not nixos, we need to source our files and need fenv
    test $isnixos -eq 0 && {
      curl -L \
        https://github.com/oh-my-fish/plugin-foreign-env/archive/refs/heads/master.tar.gz 2> /dev/null |
        tar xfz - --strip-components 2 --exclude-ignore-recursive="*.fish" -C $configpath/fish/functions
    } || :
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

  # background
  ln -s $scriptpath/dot/backgrounds ~/.backgrounds

  # picom
  ln -s $configpath/compton.cfg ~/.config/compton.cfg

  # dunst
  ln -s $configpath/dunst ~/.config/dunst

  # rofi
  ln -s $configpath/rofi ~/.config

  # hypr
  ln -s $configpath/hypr ~/.config

  # openbox
  ln -s $configpath/openbox ~/.config

  # eww
  ln -s $configpath/eww ~/.config

  # bashrc as backup
  test -n ${BASH} && test -z ${DOTFILES_LOADED+x} && {
    echo "[ -f $scriptpath/dot/bashrc ] && . $scriptpath/dot/bashrc" >> ~/.bashrc
  }

  # indicate we have run the installation
  ln -s $scriptpath/dot/dots-installed ~/.dots-installed
}

setup
