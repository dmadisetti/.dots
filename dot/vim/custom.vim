" Autoformat
augroup autoformat_settings
  autocmd FileType bzl AutoFormatBuffer buildifier
augroup END
autocmd FileType cuda let b:codefmt_formatter = 'clang-format'

" Nerdtree / Airlatex sidebar
function! ToggleAirLatexOrNERDTree()
  if exists("g:AirLatexIsActive") && g:AirLatexIsActive
    call AirLatexToggle()
  else
    NERDTreeToggle
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
  if g:MarkDowned
    :SoftPencil
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
    nnoremap <S-left> :call AirLatex_PrevChangePosition()<CR>
    nnoremap <S-right> :call AirLatex_NextChangePosition()<CR>

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

