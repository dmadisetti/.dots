if empty(glob('~/.vim/autoload/plug.vim'))
  silent !sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs
         \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source .vimrc
endif

call plug#begin('~/.vim/plugged')

" Some plugins for workflow.
Plug 'NLKNguyen/papercolor-theme'
Plug 'powerline/powerline-fonts'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'edkolev/tmuxline.vim'

Plug 'skywind3000/asyncrun.vim'

Plug 'ctrlpvim/ctrlp.vim'
Plug 'scrooloose/nerdtree', { 'on':  'NERDTreeToggle' }

Plug 'terryma/vim-multiple-cursors'
" Plug 'ervandew/screen'
Plug 'SirVer/ultisnips', { 'for': 'markdown' }
Plug 'dense-analysis/ale', { 'for' : 'cpp' }

Plug 'gabrielelana/vim-markdown', { 'for': 'markdown' }
Plug 'lervag/vimtex', { 'for': ['tex', 'markdown'] }
Plug 'KeitaNakamura/tex-conceal.vim', { 'for': 'markdown' }
Plug 'rhysd/vim-grammarous'

Plug 'junegunn/goyo.vim', { 'on': 'Goyo' }
Plug 'junegunn/limelight.vim', { 'on': 'Goyo' }

Plug 'gilligan/vim-lldb', { 'on': 'Lattach' }
" Plug 'Valloric/YouCompleteMe'
" Plug 'grailbio/bazel-compilation-database'

Plug 'tpope/vim-fugitive'

" Add maktaba and codefmt to the runtimepath.
" (The latter must be installed before it can be used.)
Plug 'google/vim-maktaba'
Plug 'google/vim-codefmt'
" Also add Glaive, which is used to configure codefmt's maktaba flags. See
" `:help :Glaive` for usage.
Plug 'google/vim-glaive'

Plug 'lpenz/vim-codefmt-haskell', { 'for': 'haskell' }

" All of your Plugins must be added before the following line
call plug#end()            " required
" Brief help
"  PlugInstall [name ...] [#threads]  Install plugins
"  PlugUpdate [name ...] [#threads]  Install or update plugins
"  PlugClean[!]  Remove unlisted plugins (bang version will clean without prompt)
"  PlugUpgrade Upgrade vim-plug itself
"  PlugStatus  Check the status of plugins
"  PlugDiff  Examine changes from the previous update and the pending changes
"  PlugSnapshot[!] [output path] Generate script for restoring the current snapshot of the plugins"
" Put your non-Plugin stuff after this line

call glaive#Install()

augroup autoformat_settings
  autocmd FileType bzl AutoFormatBuffer buildifier
augroup END

function! Multiple_cursors_before()
    " call youcompleteme#DisableCursorMovedAutocommands()
    " let b:ycm_largefile = 1
endfunction
function! Multiple_cursors_after()
    " call youcompleteme#EnableCursorMovedAutocommands()
    " unlet b:ycm_largefile
endfunction

" File type overrides
let g:MarkDowned = 0
function! Math()
    let g:MarkDowned = 1
    " syntax include @tex syntax/tex.vim
    "" Define certain regions
    " Block math. Look for "$$[anything]$$"
    syn region texMathZoneX matchgroup=mkdMaths start=/\$\$/ end=/\$\$/ contains=@texMathZoneGroup
    " inline math. Look for "$[not $][anything]$"
    syn match math_block '\$[^$].\{-}\$' contains=@texMathZoneGroup

    " syn match markdownMathNumber '\d\+' containedin=texMathZoneX,math_block,texSuperscripts
    syn match markdownMathOp '[*+\-%@=]' contains=texMathZoneX,math_block,texSuperscripts
    " syn match markdownMathConst '[A-Z]\+' containedin=texMathZoneX,math_block
    syn match markdownMathDelimiter '[[\]|(){}]' containedin=texMathZoneX,math_block contains=texMathZoneX

    "" Actually highlight those regions.
    " hi link texMathZoneX SpecialComment
    " hi link math_block Statement
    hi link markdownMathNumber Number
    hi link markdownMathOp Operator
    " hi link Special Operator
    " hi link markdownMathConst Constant
    hi link texMathSymbol Comment
    hi link markdownMathDelimiter Delimiter
    hi link texMathGreek Conditional
    hi link texStatement Comment
    hi! link Conceal markdownH1

    syn match dollas '\$'
    hi! link dollas markdownH1
    " exec 'hi Conceal' . s:fg_green . s:ft_bold
    " hi Conceal guifg=#ff0000 guibg=#00ff00
    " hi Conceal ctermfg=245
    " syntax cluster texMathZoneGroup add=@texMathZones
    " hi link math_block Function
endfunction

" Call everytime we open a Markdown file
autocmd BufRead,BufNewFile,BufEnter *.md,*.markdown call Math()

function! CustomSvg()
  syn match svgStatement '\<d\s*=\s*"[^"]*"' containedin=xmlEqual,xmlAttrib,xmlString conceal cchar=d
  set concealcursor=n
  hi link svgStatement xmlString
  hi! link Conceal xmlAttrib
endfunction

autocmd BufRead,BufNewFile,BufEnter *.svg call CustomSvg()


" Plugin Tweaks
"
" Airline
let g:airline_powerline_fonts = 1
" Custom airline_symbol (It's breaking for some reason).
" ro=⊝, ws=☲, lnr=☰, mlnr=㏑, br=ᚠ, nx=Ɇ, crypt=🔒
if !exists('g:airline_symbols')
  let g:airline_symbols = {}
endif
let g:airline_symbols.linenr = ':'
let g:airline_symbols.whitespace = ''
let g:airline_right_sep = ''
let g:airline#extensions#tmuxline#enabled = 0
let g:airline#extensions#ale#enabled = 1
let g:airline_theme='base16_ashes'

" NERDTree
let g:WebDevIconsUnicodeDecorateFolderNodes=1
let g:NERDTreeDirArrowExpandable='+'
let g:NERDTreeDirArrowCollapsible='-'
nmap <C-x> :NERDTreeToggle<CR>

" ctrlp
let g:ctrlp_show_hidden = 1
let g:ctrlp_custom_ignore = '\v[\/](node_modules|experiments|results|target|__pycache__|bazel\-*)|(\.(swp|ico|git|svn))$'

" Vimtex
let g:vimtex_latexmk_build_dir = '.vimtex'
let g:vimtex_view_general_viewer='firefox'
let g:tex_flavor = 'lualatex'

" Conceal
set conceallevel=2
let g:tex_conceal="abdgm"

" Ultisnips
let g:UltiSnipsExpandTrigger="<c-u>"
let g:UltiSnipsJumpForwardTrigger = '<c-u>'
let g:UltiSnipsListSnippets = '<c-e>'
let g:UltiSnipsSnippetsDir = "~/.vim/ulties"
let g:UltiSnipsSnippetDirectories = ["ulties"]

" ScreenShell
" let g:ScreenImpl = "Tmux"

" YCM
" let g:ycm_global_ycm_extra_conf = "/home/dylan/.vim/bundle/bazel-compilation-database/.ycm_extra_conf.py"
" let g:ycm_confirm_extra_conf = 0

let g:ale_sign_column_always = 1
let g:ale_linters = {'cpp': ['clang'], 'python': ['flake8', 'pylint']}

let g:do_auto_show_process_window = 0
" General styling
" syntax on

set guifont=RobotoMono\ Nerd\ Font\ Medium:h15
set t_Co=256   " This is may or may not needed.
set encoding=utf-8 "

set background=dark
colorscheme PaperColor
set number
set laststatus=2

set tabstop=2       " The width of a TAB is set to 2.
                    " Still it is a \t. It is just that
                    " Vim will interpret it to be having
                    " a width of 2.
set shiftwidth=2    " Indents will have a width of 2
set softtabstop=2   " Sets the number of columns for a TAB
set expandtab       " Expand TABs to spaces
set tw=80

" Personal keybindings
nnoremap <SPACE> <Nop>
let mapleader=" "

inoremap jk <C-c>:w<Cr>
inoremap kj <C-c>:w<Cr>
nnoremap Y y$

" Refresh patched ibazel
nnoremap <C-e> :AsyncRun killall -SIGUSR1 ibazel<Cr>

" Up down
vnoremap <C-j> 5j
vnoremap <C-k> 5k
nnoremap <C-j> 5j
nnoremap <C-k> 5k

" Left right
nnoremap <C-h> b
nnoremap <C-l> w
nnoremap H ^
nnoremap L $
vnoremap <C-h> b
vnoremap <C-l> w
vnoremap H ^
vnoremap L $

" Stolen from adc613
vnoremap < <gv
vnoremap > >gv

" Escape Ex Mode
cnoremap <C-Q> visual<CR>
cnoremap <C-V> visual<CR>

" Terminal mode
tmap <esc> <C-\><C-n>
tmap <C-w> <esc><C-w>

" Buffers
map <C-b> :bp<Cr>

" Markdown Tweaks
let g:markdown_enable_spell_checking = 0
function! SpellToggle()
  if g:markdown_enable_spell_checking
    setlocal nospell
    let g:markdown_enable_spell_checking = 0
    if g:MarkDowned
      :GrammarousReset
    endif
  else
    setlocal spell
    let g:markdown_enable_spell_checking = 1
    if g:MarkDowned
      :GrammarousCheck
    endif
  endif
endfunction

nnoremap <C-s> :call SpellToggle()<cr>

function! Zen()
  :Goyo
  :Limelight
endfunction

command Zen :call Zen()

" if only this wasn't so slow
" nnoremap S :ScreenShell<cr>
" vnoremap <C-S-V> :ScreenSend<cr>

" Misc Formatting
function! TrimWhitespace()
  let l:save = winsaveview()
  keeppatterns %s/\s\+$//e
  call winrestview(l:save)
endfun

nnoremap <F5> :call TrimWhitespace()<CR>:retab<CR>

" Markdown Math Optimizations
" Lol, except I forget these and hit them by accident
" imap <C-q> $
" imap <C-w> $$<Cr>$$<C-c>O
" nmap <leader>q i<C-q>
" nmap <leader>Q i<C-w>

" Debug Vim styles
map <c-I> :highlight LineNr ctermfg=grey
map <c-i> :echo "hi<" . synIDattr(synID(line("."),col("."),1),"name") . '> trans<'
\ . synIDattr(synID(line("."),col("."),0),"name") . "> lo<"
\ . synIDattr(synIDtrans(synID(line("."),col("."),1)),"name") . ">"<CR>
