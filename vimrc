"              *
"         *                *
"         _..._      *
"       .'     '.      _
"   *  /    .-""-\   _/ \
"    .-|   /:.   |  |   |
"    |  \  |:.   /.-'-./
"    | .-'-;:__.'    =/
"    .'=  *=|NVIM _.='
"   /   _.  |    ;
"  ;-.-'|    \   |     *
"  |  | \    _\  _\
"  |_/'._;.  ==' ==\     *
"          \    \   |
"          /    /   / *
"    *     /-._/-._/
"        * \   `\  \
"           `-._/._/

source ~/.vim/config/bootstrap.vim
source ~/.vim/config/plugins.vim
source ~/.vim/config/settings.vim
source ~/.vim/config/custom.vim
source ~/.vim/config/keybindings.vim

" File specific
autocmd FileType markdown source ~/.vim/config/languages/markdown.vim
autocmd FileType tex source ~/.vim/config/languages/tex.vim
autocmd FileType svg source ~/.vim/config/languages/svg.vim
