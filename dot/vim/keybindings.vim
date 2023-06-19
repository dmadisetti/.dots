" Personal keybindings
nnoremap <SPACE> <Nop>
let mapleader=" "

inoremap jk <C-c>:w<Cr>
inoremap kj <C-c>:w<Cr>
nnoremap Y y$

" Refresh patched ibazel
nnoremap <C-e> :AsyncRun killall -SIGUSR1 ibazel<Cr>
inoremap <C-e> :AsyncRun killall -SIGUSR1 ibazel<Cr>

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

" AirLatex Keybinds
"if exists("g:AirLatexIsActive") && g:AirLatexIsActive
nnoremap <F2> :call AirLatexToggleTracking()<CR>
nnoremap <F3> :call AirLatexToggleShowTracking()<CR>
nnoremap <space>n :call AirLatex_NextCommentPosition()<CR>
nnoremap <space>p :call AirLatex_PrevCommentPosition()<CR>

iunmap jk
iunmap kj
inoremap jk <Esc>:call AirLatex_SyncPDF()<CR>
inoremap kj <Esc>:call AirLatex_SyncPDF()<CR>
"endif

" NerdTree
nmap <C-x> :call ToggleAirLatexOrNERDTree()<CR>
nmap X :call AirLatexToggleComments()<CR>

" Binds to custom.vim
nnoremap <F5> :call TrimWhitespace()<CR>:retab<CR>
nnoremap <C-s> :call SpellToggle()<cr>

" Debug Vim styles
map <c-I> :highlight LineNr ctermfg=grey
map <c-i> :echo "hi<" . synIDattr(synID(line("."),col("."),1),"name") . '> trans<'
\ . synIDattr(synID(line("."),col("."),0),"name") . "> lo<"
\ . synIDattr(synIDtrans(synID(line("."),col("."),1)),"name") . ">"<CR>
