if empty(glob('~/.vim/autoload/plug.vim'))
  silent !sh -c '
    \ curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  silent !sh -c 'touch -f ~/.vim/autoload/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source .vimrc
endif
