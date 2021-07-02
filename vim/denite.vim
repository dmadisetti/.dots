autocmd FileType denite call s:denite_my_settings()
function! s:denite_my_settings() abort
  nnoremap <silent><buffer><expr> q denite#do_map('quit')
  nnoremap <silent><buffer><expr>  <CR>     denite#do_map('do_action')
  nnoremap <silent><buffer><expr>  <Space>  denite#do_map('toggle_select').'j'
  nnoremap <silent><buffer><expr>  a        denite#do_map('choose_action')
  nnoremap <silent><buffer><expr>  d        denite#do_map('do_action', 'delete')
  nnoremap <silent><buffer><expr>  p        denite#do_map('do_action', 'preview')
  nnoremap <silent><buffer><expr>  i        denite#do_map('open_filter_buffer')
  nnoremap <silent><buffer><expr>  <Esc>    denite#do_map('quit')
endfunction

nnoremap <C-q> :Denite -buffer-name=citation-start-insert  -vertical-preview citation_collection<cr>
inoremap <C-q> <C-c>:Denite -buffer-name=citation-start-insert  -vertical-preview citation_collection<cr>
