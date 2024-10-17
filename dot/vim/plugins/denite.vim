autocmd FileType denite call s:denite_my_settings()
function! s:denite_my_settings() abort
  nnoremap <silent><buffer><expr> q denite#do_map('quit')
  nnoremap <silent><buffer><expr>  <CR>     denite#do_map('do_action')
  nnoremap <silent><buffer><expr>  <Space>  denite#do_map('toggle_select').'j'
  nnoremap <silent><buffer><expr>  a        denite#do_map('choose_action')
  nnoremap <silent><buffer><expr>  d        denite#do_map('do_action', 'delete')
  nnoremap <silent><buffer><expr>  p        denite#do_map('do_action', 'preview')
  nnoremap <silent><buffer><expr>  o        denite#do_map('do_action', 'open')
  nnoremap <silent><buffer><expr>  i        denite#do_map('open_filter_buffer')
  nnoremap <silent><buffer><expr>  <Esc>    denite#do_map('quit')
endfunction

"   let plugins = remote#host#PluginsForHost(a:host)
"   for plugin in plugins
"     if plugin.path == a:path " comparision should just be updated to check denite in the name
"       throw 'Plugin "'.a:path.'" is already registered'
"     endif
"   endfor
"   call remote#host#RegisterPlugin('python3', '~/.vim/plugged/denite.nvim/rplugin/python3/denite', [
"         \ {'sync': v:true, 'name': '_denite_init', 'type': 'function', 'opts': {'nargs': '*'}},
"        \ ])

nnoremap <C-q> :Denite -buffer-name=citation-start-insert  -vertical-preview citation_collection<cr>
inoremap <C-q> <C-c>:Denite -buffer-name=citation-start-insert  -vertical-preview citation_collection<cr>

