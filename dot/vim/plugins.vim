" Brief help
"  PlugInstall [name ...] [#threads]  Install plugins
"  PlugUpdate [name ...] [#threads]  Install or update plugins
"  PlugClean[!]  Remove unlisted plugins (bang version will clean without prompt)
"  PlugUpgrade Upgrade vim-plug itself
"  PlugStatus  Check the status of plugins
"  PlugDiff  Examine changes from the previous update and the pending changes
"  PlugSnapshot[!] [output path] Generate script for restoring the current snapshot of the plugins"

" Set filetypes for vimplug
autocmd BufNewFile,BufRead *.ipynb setf ipynb

call plug#begin('~/.vim/plugged')

"" Some plugins for workflow.

" Pretty
Plug 'NLKNguyen/papercolor-theme'
Plug 'powerline/powerline-fonts'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'edkolev/tmuxline.vim'

" Bad habits
Plug 'ctrlpvim/ctrlp.vim'
Plug 'stevearc/oil.nvim', { 'on': 'Oil' }

" Productivity
Plug 'terryma/vim-multiple-cursors'
Plug 'SirVer/ultisnips', { 'for': ['tex', 'markdown', 'snippets'] }

" Markdown
Plug 'gabrielelana/vim-markdown', { 'for': ['tex', 'markdown'] }
Plug 'KeitaNakamura/tex-conceal.vim', { 'for': ['tex', 'markdown'] }
 " , { 'for': ['tex', 'markdown'] } " nav break lines
Plug 'preservim/vim-pencil'
Plug 'rhysd/vim-grammarous', { 'for': ['tex', 'markdown'] }
Plug 'AnotherGroupChat/citation.vim', {'branch': 'denite', 'for': ['tex', 'markdown']}
" Something weird with denite where UpdateRemotePlugins doesn't pick it up.
" Note denite is also retired, but whatever for now.
Plug 'Shougo/denite.nvim', { 'do': ':UpdateRemotePlugins' } ",  'for': ['markdown', 'tex'] }
Plug 'dmadisetti/paragraph-number.vim', { 'do': ':UpdateRemotePlugins' }
Plug 'lervag/vimtex'

" Zen
Plug 'junegunn/goyo.vim', { 'on': 'Goyo' }
Plug 'junegunn/limelight.vim', { 'on': 'Goyo' }

" I think I might be in love with @junegunn
" View registers before usage
" TODO: Replace with which-key :(
Plug 'junegunn/vim-peekaboo'

" More extension to base nix
Plug 'rhysd/clever-f.vim'


" Overleaf in vim!
" Plug 'da-h/AirLatex.vim'
" replaced with 'dmadisetti/AirLatex.vim' and launch through nix.

" Cpp
Plug 'gilligan/vim-lldb', { 'on': 'Lattach' }
Plug 'dense-analysis/ale', { 'for' : 'cpp' }

" Rhai
Plug 'kuon/rhai.vim', { 'for': 'rhai', 'branch': 'main'}

" Background
Plug 'skywind3000/asyncrun.vim'

" Git!
" Plug 'tpope/vim-fugitive'

" Nix'ed
Plug 'LnL7/vim-nix', { 'for': 'nix' }

" Jupyter / Python
Plug 'szymonmaszke/vimpyter', { 'for': 'ipynb' }

" Edit binary data in hex
Plug 'fidian/hexmode'

" Protobuf
Plug 'wfxr/protobuf.vim'
Plug 'cybrown-zoox/vim-pbtxt'

" Fish
Plug 'dag/vim-fish', {'for': 'fish'}

" Why no %
" Plug 'chrisbra/matchit' ", {'for': ['fish', 'bash', 'shell', 'zsh']}
" Too slow

" Sure, why not
" Plug 'neoclide/coc.nvim', {'branch': 'release'}

" All hail our AI overlord
if has('nvim-0.6')
  Plug 'nvim-lua/plenary.nvim'
  Plug 'github/copilot.vim', {'branch': 'release'}
  Plug 'CopilotC-Nvim/CopilotChat.nvim', { 'branch': 'canary' }
endif

" Maktaba + Glaive for code formatting
" TODO: LSP and tree sitters all the way?
Plug 'google/vim-maktaba'
Plug 'google/vim-codefmt'
Plug 'google/vim-glaive'
Plug 'lpenz/vim-codefmt-haskell', { 'for': 'haskell' }

" All of your Plugins must be added before the following line
call plug#end()            " required
call glaive#Install()

luafile ~/.dots/dot/vim/plugins/nvim-tree.lua
luafile ~/.dots/dot/vim/plugins/copilot.lua
luafile ~/.dots/dot/vim/plugins/headlines.lua
