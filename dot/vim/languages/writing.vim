" File type overrides
function! Math()
    set wrap lbr
    set textwidth=0
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
autocmd BufRead,BufNewFile,BufEnter *.md,*.markdown,*.tex call Math()
source ~/.dots/dot/vim/plugins/denite.vim
