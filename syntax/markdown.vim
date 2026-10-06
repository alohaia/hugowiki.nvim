" Vim plugin for writing hugo posts
" Maintainer: Qihuan Liu <liu.qihuan@outlook.com>

if exists('b:current_syntax')
    finish
endif
unlet! b:current_syntax

syn iskeyword @,48-57,192-255,$,_
syn sync fromstart

" commen delimiter
hi link HWDelimiter Comment

"--------------------------------------\ Hugo Tag /-------------------------------------
syn region HWHugoTag matchgroup=HWDelimiter keepend
    \ start='{{<\s*/\?[A-Za-z-]\+\s\+\ze' end='\s*>}}'
    \ contains=HWHugoTagArg
syn region HWHugoTag matchgroup=HWDelimiter keepend
    \ start='{{%\s*/\?[A-Za-z-]\+\s\+\ze' end='\s*%}}'
    \ contains=HWHugoTagArg
syn cluster CHWHugoTag contains=HWHugoTag

syn match   HWHugoTagArg +[A-Za-z-]\+\s*=\s*\(".\{-}"\|true\|false\|\d\+\)+ contained transparent
    \ contains=HWHugoTagArgName,@CHWHugoTagArgValue
syn match   HWHugoTagArg +".\{-}"\|true\|false\|\d\++ contained transparent
    \ contains=@CHWHugoTagArgValue
syn match   HWHugoTagArgName +[A-Za-z-]\+\ze\s*=+ contained
syn cluster CHWHugoTagArgValue
    \ contains=HWHugoTagArgSrting,HWHugoTagArgNumber,HWHugoTagArgBoolean
syn match HWHugoTagArgSrting  +".\{-}"+ contained
syn match HWHugoTagArgNumber  +\d\++ contained
syn keyword HWHugoTagArgBoolean true false contained

hi link HWHugoTagArgName    Tag
hi link HWHugoTagArgSrting  String
hi link HWHugoTagArgNumber  Number
hi link HWHugoTagArgBoolean Boolean

"---------------------------------------\ Special /-------------------------------------
" syn match MarkdownEscape /\\[\\`*{}[\]()#+.!_>~-]/
" syn match MarkdownEscapeBackslash /\\/ contained conceal
"
" hi link MarkdownEscape SpecialChar
" hi link MarkdownEscapeBackslash SpecialChar

"---------------------------------------------------------------------------------------
let b:current_syntax = 'markdown'
