function! CustomSvg()
  syn match svgStatement '\<d\s*=\s*"[^"]*"' containedin=xmlEqual,xmlAttrib,xmlString conceal cchar=d
  set concealcursor=n
  hi link svgStatement xmlString
  hi! link Conceal xmlAttrib
endfunction

autocmd BufRead,BufNewFile,BufEnter *.svg call CustomSvg()
