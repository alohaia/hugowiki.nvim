" Vim plugin for writing hexo posts
" Maintainer: Qihuan Liu <liu.qihuan@outlook.com>

if exists('b:current_syntax')
  finish
endif

runtime syntax/markdown.vim
unlet! b:current_syntax

" if exists('g:markdown_fenced_languages')
"   if !exists('g:rmd_fenced_languages')
"     let g:rmd_fenced_languages = deepcopy(g:markdown_fenced_languages)
"     " let g:markdown_fenced_languages = []
"   endif
" else
"   let g:rmd_fenced_languages = ['r']
" endif

" Now highlight chunks:
syn include @HWIncludeCode_r syntax/r.vim
syn region HWCodeInDelimiter matchgroup=HWCodeDelimiterStart_r start="^\s*```\s*{\s*r\>" end="}$" keepend containedin=HWCodeBlock_r contains=@HWIncludeCode_r
syn region HWCodeBlock_r keepend contains=HWCodeInDelimiter,@HWIncludeCode_r
    \ start="^\s*```\s*{\s*r\>.*$" matchgroup=HWCodeDelimiterEnd_r end="^\s*```\ze\s*$"

" Recognize inline R code
syn region rmdrInline matchgroup=HWInlineCodeDelimiter start="`r "  end="`" contains=@HWIncludeCode_r keepend

hi def link rmdInlineDelim Delimiter
hi def link rmdCodeDelim Delimiter

let b:current_syntax = 'markdown'
