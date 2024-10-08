" Vim plugin for writing hugo posts
" Maintainer: Qihuan Liu <liu.qihuan@outlook.com>

if exists('b:current_syntax')
  finish
endif
if !exists('main_syntax')
  let main_syntax = 'markdown'
endif
runtime! syntax/html.vim
unlet! b:current_syntax

syn iskeyword @,48-57,192-255,$,_
syn sync fromstart

" commen delimiter
hi link HWDelimiter Comment

" bad spell
hi SpellBad gui=undercurl guifg=red
hi SpellRare gui=undercurl,italic
hi SpellLocal gui=undercurl,italic
hi SpellCap gui=undercurl
" conceal
hi link Conceal Normal

"======================================\ Special /======================================

syn include @CHWIncludeCode_yaml syntax/yaml.vim
syn region HWHeader contains=@CHWIncludeCode_yaml keepend
    \ matchgroup=HWHeaderDelimiter start='\%^---$' end='^---$'
hi link HWHeader Define
hi link HWHeaderDelimiter yamlDocumentStart

syn match HWLine '^-----*$'
hi link HWLine Comment

"=======================================\ Inline /======================================

syn cluster CHWInline
    \ contains=@CHWInlineSpecial,@CHWEnclosed,@CHWInlineCM,HWFootnote,@CHWHugoTag,
    \   @CHWLink,@CHWTextDeclaration,htmlTag
syn cluster CHWWholeLine
    \ contains=HWFootnoteDefination,HWImage,@CHWHeading,@HWReference

"--------------------------------------\ Special /--------------------------------------
syn keyword HWKeyword TODO Same See
syn match HWEscape '\\.'he=e-1
syn match HWEmoji ':\w\+:'
syn cluster CHWInlineSpecial contains=HWKeyword,HWEscape,HWEmoji

hi link HWKeyword Keyword
hi link HWEscape Comment
hi link HWEmoji Special

"--------------------------------------\ Enclosed /-------------------------------------
syn match HWString contains=@Spell,@CHWInline +".\{-}"+ contains=ALL
syn match HWString contains=@Spell,@CHWInline +\(\s\|^\)\zs'.\{-}'\ze\(\s\|$\)+ contains=ALL
syn match HWString contains=@Spell,@CHWInline +“.\{-}”+ contains=ALL
syn match HWString contains=@Spell,@CHWInline +‘.\{-}’+ contains=ALL
syn cluster CHWEnclosed contains=HWString

hi link HWString String

"---------------------------------\ Inline Code & Math /--------------------------------
syn include @CHWIncludeCode_tex syntax/tex.vim
syn region HWInlineCode matchgroup=HWCodeDelimiter keepend oneline start=+`+ end=+`+
syn region HWInlineCode matchgroup=HWCodeDelimiter keepend oneline start=+``+ end=+``+
syn region HWInlineMath matchgroup=HWDelimiter oneline start=+\$+ end=+\$+ skip=+\\\$+
    \ contains=@CHWIncludeCode_tex

syn cluster CHWInlineCM contains=HWInlineCode,HWInlineMath

hi link HWCodeDelimiter PreProc
hi link HWInlineCode String
hi link HWInlineMath PreProc

"------------------------------------\ Link & Image /-----------------------------------

syn match HWRawLink '\(ftp\|file\|ftp\|ftps\|gemini\|git\|gopher\|https\?\|irc\|ircs\|kitty\|mailto\|news\|sftp\|ssh\)://[^ ]\+' keepend
syn match HWRawLink 'www\.\a\+\.\a\+\(/[^ ]*\)\?' keepend
syn match _HWRawLinkId +#.\++ contained
syn match _HWRawLinkRel +/.\++ contained

syn match HWLink +\[[^[]\{-1,}\](.\{-1,})+ keepend contains=HWLinkText,HWLinkTarget
syn match HWImage +!\[.\{-}\](.\{-1,})+ contains=HWLinkText,HWLinkTarget
syn match HWLinkText +\[\zs.\{-1,}\ze\]+ keepend contained contains=@Spell,@CHWInline
syn match HWLinkTarget +(\zs.\{-1,}\ze)+ keepend contained contains=HWRawLink,_HWRawLinkId,_HWRawLinkRel,HWHugoTagRef transparent

syn cluster CHWLink contains=HWLink,HWRawLink

hi link HWLink HWDelimiter
hi link HWImage HWDelimiter

hi _HWLink cterm=underline gui=underline guifg=#48aff0
hi link HWRawLink     _HWLink
hi link HWLinkText    _HWLink
hi link _HWRawLinkId  _HWLink
hi link _HWRawLinkRel _HWLink

"-------------------------------------\ Foot Note /-------------------------------------
syn region HWFootnote matchgroup=HWDelimiter keepend oneline
    \ start='\S\zs\[\ze\^' end='\]:\@<!' skip='\\]'
    \ contains=@Spell
syn region HWFootnoteDefination matchgroup=HWDelimiter keepend oneline
    \ start='^\[\ze\^' end='\]:\s' skip='\\]:\s'
    \ contains=@Spell

hi link HWFootnote           _HWLink
hi link HWFootnoteDefination _HWLink

"--------------------------------------\ Hugo Tag /-------------------------------------
syn region HWHugoTag matchgroup=HWDelimiter keepend
    \ start='{{<\s*/\?' end='\s*>}}'
    \ contains=HWHugoTagItem
syn region HWHugoTag matchgroup=HWDelimiter keepend
    \ start='{{%\s*/\?' end='\s*%}}'
    \ contains=HWHugoTagItem
syn region HWHugoTagRef matchgroup=HWDelimiter keepend
    \ start=+{{<\s*\(rel\)\?ref\s\+"+ end=+"\s*>}}+
    \ contains=HWHugoTagItem
syn cluster CHWHugoTag contains=HWHugoTag,HWHugoTagRef

syn match   HWHugoTagItem +[A-Za-z-]\+\s\?=\s\?\(".\{-}"\|true\|false\|\d*\)+ contained
    \ contains=HWHugoTagItemName,@CHWHugoTagItemValue
syn match   HWHugoTagItemName  +[A-Za-z-]*\ze\s\?=\s\?\&+ contained
syn cluster CHWHugoTagItemValue
    \ contains=HWHugoTagItemSrting,HWHugoTagItemNumber,HWHugoTagItemBoolean
syn match   HWHugoTagItemSrting  +".\{-}"+
syn match   HWHugoTagItemNumber  +\d\++ contained
syn keyword HWHugoTagItemBoolean true false contained

hi link HWHugoTag htmlTagName
hi link HWHugoTagItemName htmlArg
hi link HWHugoTagItemSrting  String
hi link HWHugoTagItemNumber  Number
hi link HWHugoTagItemBoolean Boolean

"----------------------------------\ Text declaration /---------------------------------
syn region HWInsert matchgroup=HWDelimiter oneline keepend
    \ start=+<ins>+ end=+</ins>+
    \ contains=@Spell,@CHWInline
syn region HWInsert matchgroup=HWDelimiter oneline
    \ start=+==+ end=+==+ skip=+\\=\\=+
    \ contains=@Spell,@CHWInline
syn region HWDelete matchgroup=HWDelimiter oneline keepend
    \ start=+[^~]\{-}\zs\~\~+ end=+\~\~\ze[^~]\{-}+ skip=+\\\~\\\~+
    \ contains=@Spell,@CHWInline
syn region HWItalic matchgroup=HWDelimiter oneline keepend
    \ start=+\*+ end=+\*+ skip='\\\*'
    \ contains=@Spell,@CHWInline
syn region HWBold matchgroup=HWDelimiter oneline keepend
    \ start=+\*\*+ end=+\*\*+ skip=+\\\*\\\*+
    \ contains=@Spell,@CHWInline
syn region HWItalicBold matchgroup=HWDelimiter oneline
    \ start=+\*\*\*+ end=+\*\*\*+ skip=+\\\*\\\*\*+
    \ contains=@Spell,@CHWInline
syn region HWSup matchgroup=HWDelimiter oneline
    \ start=+\^+ end=+\^+ skip=+\\\^+
    \ contains=@Spell,@CHWInline
syn region HWSub matchgroup=HWDelimiter oneline
    \ start=+\~+ end=+\~+ skip=+\\\~+
    \ contains=@Spell,@CHWInline
syn region HWHighlight matchgroup=HWDelimiter oneline
    \ start=+<mark>+ end=+</mark>+
    \ contains=@Spell,@CHWInline
syn region HWHighlight matchgroup=HWDelimiter oneline
    \ start=+==+ end=+==+
    \ contains=@Spell,@CHWInline

syn cluster CHWTextDeclaration
    \ contains=HWInsert,HWDelete,HWItalic,HWBold,HWItalicBold,HWSup,HWSub,HWHighlight

hi HWInsert cterm=underline gui=underline
hi HWDelete cterm=strikethrough gui=strikethrough ctermfg=204 guifg=#E06C75
hi HWItalic cterm=italic gui=italic
hi HWBold cterm=bold gui=bold
hi HWItalicBold cterm=italic,bold gui=italic,bold
hi HWHighlight cterm=standout gui=standout

"--------------------------------------\ Heading /--------------------------------------
syn region HWHeading1 matchgroup=HWH1Delimiter start='^#\s\+'      end='$' keepend oneline
    \ contains=@Spell,@CHWTextDeclaration,HWInlineCode
syn region HWHeading2 matchgroup=HWH2Delimiter start='^##\s\+'     end='$' keepend oneline
    \ contains=@Spell,@CHWTextDeclaration,HWInlineCode
syn region HWHeading3 matchgroup=HWH3Delimiter start='^###\s\+'    end='$' keepend oneline
    \ contains=@Spell,@CHWTextDeclaration,HWInlineCode
syn region HWHeading4 matchgroup=HWH4Delimiter start='^####\s\+'   end='$' keepend oneline
    \ contains=@Spell,@CHWTextDeclaration,HWInlineCode
syn region HWHeading5 matchgroup=HWH5Delimiter start='^#####\s\+'  end='$' keepend oneline
    \ contains=@Spell,@CHWTextDeclaration,HWInlineCode
syn region HWHeading6 matchgroup=HWH6Delimiter start='^######\s\+' end='$' keepend oneline
    \ contains=@Spell,@CHWTextDeclaration,HWInlineCode

syn region HWHeadingAttr matchgroup=HWDelimiter start=+{+ end=+}+ keepend oneline contained
    \ containedin=HWHeading1,HWHeading2,HWHeading3,HWHeading4,HWHeading5,HWHeading6
    \ contains=HWHeadingAttrClass,HWHeadingAttrId,HWHeadingAttrItem
syn match HWHeadingAttrClass +\.\S\++ contained
syn match HWHeadingAttrId +#\S\++ contained
syn match HWHeadingAttrItem +\w\+\s*=\s*\("[^"]\{-}"\|'[^']\{-}'\|\w\+\)+ contained contains=HWHeadingAttrItemName,HWHeadingAttrItemValue
syn match HWHeadingAttrItemName +\w\++ contained
syn match HWHeadingAttrItemValue +=\s*\zs"[^"]*"+ contained
syn match HWHeadingAttrItemValue +=\s*\zs'[^']*'+ contained
syn match HWHeadingAttrItemValue +=\s*\zs\w\++ contained

syn cluster CHWHeading contains=HWHeading1,HWHeading2,HWHeading3,HWHeading4,HWHeading5,HWHeading6

hi HWHeading1 cterm=bold gui=bold ctermfg=9  guifg=#e08090
hi HWHeading2 cterm=bold gui=bold ctermfg=10 guifg=#80e090
hi HWHeading3 cterm=bold gui=bold ctermfg=12 guifg=#6090e0
hi HWHeading4 cterm=bold gui=bold ctermfg=15 guifg=#c0c0f0
hi HWHeading5 cterm=bold gui=bold ctermfg=15 guifg=#d5d5d5
hi HWHeading6 cterm=bold gui=bold ctermfg=15 guifg=#f9f9f9
hi HWLine     cterm=bold gui=bold ctermfg=59 guifg=#5C6370

hi link HWH1Delimiter HWDelimiter
hi link HWH2Delimiter HWDelimiter
hi link HWH3Delimiter HWDelimiter
hi link HWH4Delimiter HWDelimiter
hi link HWH5Delimiter HWDelimiter
hi link HWH6Delimiter HWDelimiter

hi link HWHeadingAttrClass Identifier
hi link HWHeadingAttrId Identifier
hi link HWHeadingAttrItemValue String
hi link HWHeadingAttrItemName htmlArg

"-------------------------------------\ Reference /-------------------------------------
syn region HWReference oneline
    \ start=+^\(>\s*\)\++ end=+$+
    \ contains=@Spell,@CHWInline,HWReference,HWCodeBlock,HWMathBlock,HWListMarker
syn match HWReferenceHead +\(^[>\t ]*\)\@<=>\ze\s*+ contained containedin=HWReference conceal cchar=▍

hi link HWReference Comment
hi link HWReferenceHead Comment

"===================================\ Multiple Line /===================================

"-------------------------------------\ Code Block /------------------------------------
syn region HWCodeBlock keepend
    \ matchgroup=HWCodeDelimiterStart start="^\s*````*.*$"
    \ matchgroup=HWCodeDelimiterEnd end="^\s*````*\ze\s*$"

let g:markdown_fenced_languages = get(g:, 'markdown_fenced_languages', [])
let s:done_include = {}
for s:type in map(copy(g:markdown_fenced_languages),'matchstr(v:val,"[^=]*$")')
  if has_key(s:done_include, matchstr(s:type,'[^.]*'))
    continue
  endif
  exe 'syn include @CHWIncludeCode_'.substitute(s:type,'\.','','g').' syntax/'.matchstr(s:type,'[^.]*').'.vim'
  exe 'syn region HWCodeBlock_'.substitute(s:type,'\.','','g')
              \ .' matchgroup=HWCodeDelimiterStart start=/^```'.s:type.'[ \n]/ matchgroup=HWCodeDelimiterEnd end=/^```$/'
              \ .' contains=@CHWIncludeCode_'.substitute(s:type,'\.','','g').' keepend'
  unlet! b:current_syntax
  let s:done_include[matchstr(s:type,'[^.]*')] = 1
endfor
unlet! s:type
unlet! s:done_include

hi link HWCodeDelimiterStart String
hi link HWCodeDelimiterEnd   String

"-------------------------------------\ Math Block /------------------------------------
syn region HWMathBlock contains=@HWIncludeCode_tex keepend display
    \ matchgroup=HWMathDelimiterStart start='^\s*\$\$\ze.*' matchgroup=HWMathDelimiterEnd end='\s*.*\zs\$\$$'

hi link HWMathDelimiterStart HWDelimiter
hi link HWMathDelimiterEnd   HWDelimiter
hi link HWMathBlock PreProc

"---------------------------------------\ lists /---------------------------------------
syn match HWListMarker '^\s*\zs\(\d\+\.\|\d\+)\)\ze\s\+'
syn match HWListMarker '^\s*\zs\(-\|\*\|+\)\ze\s\+' conceal cchar=•
syn match HWCheckListMarker '^\s*\zs\(\(-\|\*\|+\) \)\?\[[ X]\]\ze\s\+'

hi link HWListMarker Label
hi link HWCheckListMarker Label

"---------------------------------------\ Define /--------------------------------------
syn match HWDefine transparent +^[^:~\t ].*\n\(\s*[:~]\s\+.*\n\)\++
    \ contains=@CHWInline,HWReference,HWCodeBlock,HWMathBlock,HWListMarker,
    \   HWDefineHead,HWDefineContent,
syn match HWDefineHead +^[^:~\t ].*$+ contained keepend
    \ contains=@Spell,@CHWInline
syn region HWDefineContent matchgroup=HWDelimiter contained keepend
    \ start=+^\s*[:~]\s\++ end=+$+
    \ contains=@Spell,@CHWInline,HWReference,HWCodeBlock,HWMathBlock,HWListMarker,

hi HWDefineHead cterm=bold gui=bold
hi link HWDefineContent Comment

"-------------------------\ hugowiki_spellcheck_ignore_upcase /-------------------------
if g:hugowiki_spellcheck_ignore_upcase
    syn match HWExCapitalWords +\<\w*[0-9A-Z]\K*\>\|'s+ transparent containedin=ALL contains=@NoSpell
    syn match HWExCapitalWords +\<\w*[0-9A-Z]\K*\>\|'s+ contains=@NoSpell
endif

let b:current_syntax = 'markdown'
if main_syntax ==# 'markdown'
  unlet main_syntax
endif
