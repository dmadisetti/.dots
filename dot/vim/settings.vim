" General and Plugin Tweaks

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

" Goyo
let g:goyo_width = 160

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
let g:pencil#conceallevel = 0
let g:pencil#wrapModeDefault = 'soft'   " default is 'hard'

" Ultisnips
let g:UltiSnipsExpandTrigger="<c-u>"
let g:UltiSnipsJumpForwardTrigger = '<c-u>'
let g:UltiSnipsListSnippets = '<c-e>'
let g:UltiSnipsSnippetsDir = "~/.vim/ulties"
let g:UltiSnipsSnippetDirectories = ["ulties"]

" Citation for PhD work
let g:citation_vim_bibtex_file="~/phd/notes/bibtex.bib"
let g:citation_vim_mode="bibtex"
let g:citation_vim_cache_path="~/.vim/citation.cache"

" Air Latex
let g:AirLatexCookieDB="~/.mozilla/firefox/*.default/cookies.sqlite"
let g:AirLatexUseDropbox = 1
" let g:AirLatexLogLevel="DEBUG"

" Linters
let g:ale_sign_column_always = 1
let g:ale_linters = {'cpp': ['clang'], 'python': ['flake8', 'pylint']}

let g:do_auto_show_process_window = 0

" Custom flags
let g:spell_checking = 0
let g:MarkDowned = 0

" Played around with trying to get this to work with tree sitters, but didn't
" like it.
let g:markdown_fenced_languages = ['python', 'javascript', 'bash=sh',
      \ '{python}=python', '{.python.marimo}=python']

" General styling
set guifont=RobotoMono\ Nerd\ Font\ Medium:h15
set t_Co=256   " This is may or may not needed.
set encoding=utf-8 "

set background=dark
colorscheme PaperColor
set number
set laststatus=2

" Force tabs to be 2 spaces in python as well.
let g:python_recommended_style = 0
set tabstop=2       " The width of a TAB is set to 2.
                    " Still it is a \t. It is just that
                    " Vim will interpret it to be having
                    " a width of 2.
set shiftwidth=2    " Indents will have a width of 2
set softtabstop=2   " Sets the number of columns for a TAB
set expandtab       " Expand TABs to spaces
set tw=80

" 'Fix' <C-a> to increment
set nrformats+=unsigned

" Persistent undo is great
set undofile
set undodir=~/.vim

" No mouse!
set mouse=
