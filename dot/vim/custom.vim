" Autoformat
augroup autoformat_settings
  autocmd FileType bzl AutoFormatBuffer buildifier
augroup END
autocmd FileType cuda let b:codefmt_formatter = 'clang-format'

let g:NetrwIsOpen=0

function! ToggleNetrw()
  if g:NetrwIsOpen
    let i = bufnr("$")
    while (i >= 1)
      if (getbufvar(i, "&filetype") == "oil")
        silent exe "bwipeout " . i
      endif
      let i-=1
    endwhile
    let g:NetrwIsOpen=0
  else
    let g:NetrwIsOpen=1
    " Doesn't exist? Open it
    " Calculate 32% of the width of the window
    let width = float2nr(winwidth(0) * 0.16)
    " Open a vertical split and resize it
    execute 'vsplit | vertical resize' width '| Oil'
  endif
endfunction

" Played with a few things, but typically, I just use ctrl-P
" So better to have a useful utility than a file navigator.
function! ToggleAirLatexOrNERDTree()
  if exists("g:AirLatexIsActive") && g:AirLatexIsActive
    call AirLatexToggle()
  else
    call ToggleNetrw()
  endif
endfunction

" Spell checking
function! SpellToggle()
  if g:spell_checking
    setlocal nospell
    let g:spell_checking = 0
    if g:MarkDowned
      :GrammarousReset
    endif
  else
    setlocal spell
    let g:spell_checking = 1
    if g:MarkDowned
      :GrammarousCheck
    endif
  endif
endfunction

" Misc Formatting
function! TrimWhitespace()
  let l:save = winsaveview()
  keeppatterns %s/\s\+$//e
  call winrestview(l:save)
endfun

" Such peace, much wow
function! Zen()
  :Goyo
  :SoftPencil
  if g:MarkDowned
    :highlight CursorLineNR ctermbg=236 ctermfg=240
    :highlight Hidden ctermbg=234 ctermfg=234
    :highlight LineNum ctermbg=234 ctermfg=238
    :set signcolumn=yes:5
    :set cursorline
    :set number
    " TODO: Share this plugin with the world.
    :ParagraphNumberToggle
  endif
  " AirLatex Keybinds
  if exists("g:AirLatexIsActive") && g:AirLatexIsActive
    nnoremap <F2> :call AirLatexToggleTracking()<CR>
    nnoremap <F3> :call AirLatexToggleShowTracking()<CR>
    nnoremap <space>n :call AirLatex_NextCommentPosition()<CR>
    nnoremap <space>p :call AirLatex_PrevCommentPosition()<CR>
    nnoremap <left> :call AirLatex_PrevCommentPosition()<CR>
    nnoremap <right> :call AirLatex_NextCommentPosition()<CR>
    nnoremap <S-up> :call AirLatex_PrevChangePosition()<CR>
    nnoremap <S-down> :call AirLatex_NextChangePosition()<CR>

    iunmap jk
    iunmap kj
    inoremap jk <Esc>:call AirLatex_SyncPDF()<CR>
    inoremap kj <Esc>:call AirLatex_SyncPDF()<CR>
  else
    :Limelight
  endif
endfunction

command Zen :call Zen()

" copilot tweaks
" ctrl-F classic emacs forwards
imap <silent><script><expr> <C-F> copilot#Accept("\<CR>")
let g:copilot_no_tab_map = v:true
" Suggestion color really needs to change because of Zen mode
highlight CopilotSuggestion guifg=#000000 ctermfg=8

