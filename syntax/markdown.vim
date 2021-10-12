" Vim plugin for writing hexo posts
" Maintainer: Qihuan Liu <liu.qihuan@outlook.com>

if exists('b:current_syntax')
  finish
endif

"+-------------------------------------------------------------------------------------+
"|                                     \ Syntax /                                      |
"+-------------------------------------------------------------------------------------+

"=======================================\ Beyond /======================================

"------------------------------------\ Pre-Settings /-----------------------------------
syn iskeyword @,48-57,192-255,$,_
syn sync fromstart

"---------------------------------------\ Header /--------------------------------------
syn include @HWIncludeYamlHeader syntax/yaml.vim
syn region HWHeader contains=@HWIncludeYamlHeader keepend
    \ start='\%^---$' end='^---$'

"--------------------------------------\ Comment /--------------------------------------
syn match HWComment '<!--.*-->'

"----------------------------------------\ Line /---------------------------------------
syn match  HWLine '^-----*$'

"-------------------------------------\ Code Block /------------------------------------
syn region HWInlineCode matchgroup=HWInlineCodeDelimiter keepend oneline concealends
    \ start="`" end="`"
syn region HWInlineCode matchgroup=HWInlineCodeDelimiter keepend oneline concealends
    \ start="`` \=" end=" \=``"
syn region HWInlineCode matchgroup=HWInlineCodeDelimiter keepend oneline concealends
    \ start="``` \=" end=" \=```"
syn region HWCodeBlock matchgroup=HWCodeDelimiterStart start="^\s*````*.*$" matchgroup=HWCodeDelimiterEnd end="^\s*````*\ze\s*$" keepend

let g:markdown_fenced_languages = get(g:, 'markdown_fenced_languages', [])
let s:done_include = {}
for s:type in map(copy(g:markdown_fenced_languages),'matchstr(v:val,"[^=]*$")')
  if has_key(s:done_include, matchstr(s:type,'[^.]*'))
    continue
  endif
  exe 'syn include @HWIncludeCode_'.substitute(s:type,'\.','','g').' syntax/'.matchstr(s:type,'[^.]*').'.vim'
  exe 'syn region HWCodeBlock_'.substitute(s:type,'\.','','g').
              \ ' matchgroup=HWCodeDelimiterStart start=/^```'.s:type.'[ \n]/ matchgroup=HWCodeDelimiterEnd end=/^```$/ contains=@HWIncludeCode_'
              \ .substitute(s:type,'\.','','g').' keepend'
  unlet! b:current_syntax
  let s:done_include[matchstr(s:type,'[^.]*')] = 1
endfor
unlet! s:type
unlet! s:done_include

"----------------------------------------\ Math /---------------------------------------
syn include @HWIncludeMath syntax/tex.vim
syn region HWInlineMath matchgroup=HWMathDelimiter contains=@HWIncludeMath keepend oneline concealends display
    \ start='[^$]*\zs\$\ze[^$]*' end='[^$]*\zs\$\ze[^$]*'
syn region HWMathBlock contains=@HWIncludeMath keepend concealends display
    \ matchgroup=HWMathDelimiterStart start='^\s*\$\$\ze.*' matchgroup=HWMathDelimiterEnd end='\s*.*\zs\$\$$'

syn cluster CHWInlineCM contains=HWInlineCode,HWInlineMath

"---------------------------------------\ Footer /--------------------------------------
syn region HWFooterAnchor matchgroup=HWFooterAnchorDelimiter keepend concealends oneline
    \ start='\[\ze\^' end='\]\ze\([^:]\|\n\)' skip='\\]'
syn region HWFooter matchgroup=HWFooterDelimiter keepend concealends oneline
    \ start='^\[\ze\^' end='\]\ze: .*$' skip='\\]'
    \ contains=HWEmoji,HWKeyword,@CHWLink,@CHWInlineCM,@CHWTextDeclaration,@CHWInlineTag,
    \   @CHWOthersInline

"----------------------------------------\ Abbr /---------------------------------------
syn match HWAbbr '^\*\[.*\]: .*$' keepend
    \ contains=HWEmoji,HWKeyword,@CHWLink,@CHWInlineCM,@CHWTextDeclaration,@CHWInlineTag,
    \   HWAbbrHead
syn region HWAbbrHead matchgroup=HWAbbrHeadDelimiter contained keepend concealends oneline
    \ start='^\*\zs\[' end='\]\ze:\s\+'

"------------------------------------\ Tags plugin /------------------------------------
syn region HWTag matchgroup=HWTagDelimiter contains=@NoSpell,HWTag oneline concealends
    \ start='{%\s*' end='\s*%}'
syn region HWTagCodeBlock matchgroup=HWTagCodeBlockDelimiter contains=@NoSpell concealends
    \ start='^{%\s*\z(codeblock\s\+.\{-1,}\)\s*%}$' end='{%\s*endcodeblock\s*%}'
syn region HWTagPostLink matchgroup=HWTagPostLinkDelimiter contains=@NoSpell oneline concealends
    \ start=+{%\s*post_link\s\+\S\+\s\++ end=+\s\+\(true\|false\)\s*%}+
syn region HWTagPostLink matchgroup=HWTagPostLinkDelimiter contains=@NoSpell oneline concealends
    \ start=+{%\s*post_link\s\+\S\+\s\+['"]+ end=+['"]\s\+\(true\|false\)\s*%}+

syn cluster CHWInlineTag contains=HWTag,HWTagPostLink,HWTagHideText
syn cluster CHWTagBlock  contains=HWTagCodeBlock

"=======================================\ Inline /======================================

"---------------------------------------\ Escape /--------------------------------------
syn match HWEscape '\\\ze.' conceal

"--------------------------------------\ Keywords /-------------------------------------
syn keyword HWKeyword TODO Same See toc TOC

"---------------------------------------\ Emoji /---------------------------------------
syn match HWEmoji ':\w\+:'

"------------------------------\ Original link or image /------------------------------
syn region HWLink matchgroup=HWLinkDelimiter keepend oneline concealends
    \ start='!\?\zs\[\ze.\{-1,}' end='\](.\{-1,})'
    \ contains=@NoSpell,HWEmoji,HWKeyword,@CHWInlineCM,@CHWTextDeclaration,@CHWInlineTag
syn region HWLink matchgroup=HWLinkDelimiter keepend oneline concealends
    \ start='!\?\zs\[\](' end=')'
    \ contains=@NoSpell
syn region HWHtmlLink matchgroup=HWHtmlLinkDelimiter keepend oneline concealends
    \ start='<a.\{-}>' end='</a>'
    \ contains=@NoSpell,HWEmoji,HWKeyword,@CHWInlineCM,@CHWTextDeclaration,@CHWInlineTag
syn match  HWRawLink '\(https\?\|ftp\)://[^ ]\+' contains=@NoSpell keepend

syn cluster CHWLink contains=HWLink,HWHtmlLink,HWRawLink

"----------------------------------\ Text declaration /---------------------------------
syn region HWSub keepend oneline
    \ start='[^~]\{-}\zs\~' end='\~\ze[^~]\{-}' skip='\\\~'
    \ contains=HWInsert,HWDelete,HWItalic,HWBold,HWHighlight,HWItalicBold,
    \   HWEmoji,HWKeyword,@CHWLink,@CHWInlineCM,@CHWTextDeclaration,@CHWInlineTag,
    \   @CHWOthersInline
syn region HWSup keepend oneline
    \ start='[^^]\{-}\zs\^' end='\^\ze[^^]\{-}' skip='\\\^'
    \ contains=HWSub,HWInsert,HWDelete,HWItalic,HWBold,HWHighlight,HWItalicBold,
    \   HWEmoji,HWKeyword,@CHWLink,@CHWInlineCM,@CHWTextDeclaration,@CHWInlineTag,
    \   @CHWOthersInline
syn region HWInsert matchgroup=HWInsertDelimiter keepend oneline concealends
    \ start='[^+]\{-}\zs++' end='++\ze[^+]\{-}' skip='\\++'
    \ contains=HWSub,HWSup,HWDelete,HWItalic,HWBold,HWHighlight,HWItalicBold,
    \   HWEmoji,HWKeyword,@CHWLink,@CHWInlineCM,@CHWTextDeclaration,@CHWInlineTag,
    \   @CHWOthersInline
syn region HWDelete matchgroup=HWDeleteDelimiter keepend oneline concealends
    \ start='[^~]\{-}\zs\~\~' end='\~\~\ze[^~]\{-}' skip='\\\~\~'
    \ contains=HWSub,HWSup,HWInsert,HWItalic,HWBold,HWHighlight,HWItalicBold,
    \   HWEmoji,HWKeyword,@CHWLink,@CHWInlineCM,@CHWTextDeclaration,@CHWInlineTag,
    \   @CHWOthersInline
syn region HWItalic matchgroup=HWItalicDelimiter keepend oneline concealends
    \ start='\*' end='\*' skip='\\\*'
    \ contains=HWSub,HWSup,HWInsert,HWDelete,HWBold,HWHighlight,
    \   HWEmoji,HWKeyword,@CHWLink,@CHWInlineCM,@CHWTextDeclaration,@CHWInlineTag,
    \   @CHWOthersInline
syn region HWBold matchgroup=HWBoldDelimiter keepend oneline concealends
    \ start='\*\*' end='\*\*' skip='\\\*\*'
    \ contains=HWSub,HWSup,HWInsert,HWDelete,HWItalic,HWHighlight,
    \   HWEmoji,HWKeyword,@CHWLink,@CHWInlineCM,@CHWTextDeclaration,@CHWInlineTag,
    \   @CHWOthersInline
syn region HWItalicBold matchgroup=HWItalicBoldDelimiter keepend oneline concealends
    \ start='\*\*\*' end='\*\*\*' skip='\\\*\*\*'
    \ contains=HWSub,HWSup,HWInsert,HWDelete,HWItalic,HWHighlight,
    \   HWEmoji,HWKeyword,@CHWLink,@CHWInlineCM,@CHWTextDeclaration,@CHWInlineTag,
    \   @CHWOthersInline
syn region HWHighlight matchgroup=HWHighlightDelimiter keepend oneline concealends
    \ start='[^=]\{-}\zs==' end='==\ze[^=]\{-}' skip='\\=='
    \ contains=HWSub,HWSup,HWInsert,HWDelete,HWItalic,HWBold,HWItalicBold,
    \   HWEmoji,HWKeyword,@CHWLink,@CHWInlineCM,@CHWTextDeclaration,@CHWInlineTag,
    \   @CHWOthersInline

syn cluster CHWTextDeclaration contains=HWSub,HWSup,HWInsert,HWDelete,HWItalic,HWBold,HWItalicBold,HWHighlight

"========================================\ Line /=======================================

"---------------------------------------\ lists /---------------------------------------
syn match HWList '^\s*\zs\(\d\+\.\|\d\+)\|-\|\*\|+\)\ze\s\+'
    \ contains=HWEmoji,HWKeyword,@CHWLink,@CHWInlineCM,@CHWTextDeclaration,@CHWInlineTag,
    \   @CHWOthersInline

"--------------------------------------\ Heading /--------------------------------------
syn region HWHeading1 matchgroup=HWH1Delimiter start='^#\s\+'      end='$' keepend oneline
    \ contains=@CHWTextDeclaration
syn region HWHeading2 matchgroup=HWH2Delimiter start='^##\s\+'     end='$' keepend oneline
    \ contains=@CHWTextDeclaration
syn region HWHeading3 matchgroup=HWH3Delimiter start='^###\s\+'    end='$' keepend oneline
    \ contains=@CHWTextDeclaration
syn region HWHeading4 matchgroup=HWH4Delimiter start='^####\s\+'   end='$' keepend oneline
    \ contains=@CHWTextDeclaration
syn region HWHeading5 matchgroup=HWH5Delimiter start='^#####\s\+'  end='$' keepend oneline
    \ contains=@CHWTextDeclaration
syn region HWHeading6 matchgroup=HWH6Delimiter start='^######\s\+' end='$' keepend oneline
    \ contains=@CHWTextDeclaration

syn match  HWHeading2 '^.*$\n\ze-----*$' keepend
    \ contains=@CHWTextDeclaration

syn cluster CHWHeading contains=HWHeading1,HWHeading2,HWHeading3,HWHeading4,HWHeading5,HWHeading6

"=======================================\ Block /=======================================

"-------------------------------------\ Reference /-------------------------------------
syn region HWReference oneline
    \ start='^\s*>\s*' end='$'
    \ contains=HWEmoji,HWKeyword,@CHWLink,@CHWInlineCM,@CHWTextDeclaration,@CHWInlineTag,
    \   HWReference,HWCodeBlock,HWMathBlock,HWList,@CHWTagBlock,
    \   HWReferenceHead,
    \   @CHWOthersInline
syn match  HWReferenceHead '^\s*>'hs=e contains=HWReferenceHead nextgroup=HWReference contains=HWReferenceHead contained conceal cchar=▊

"---------------------------------------\ Define /--------------------------------------
syn region HWDefine keepend transparent
    \ start='^[^:~\u0020\u0009].*\n\+\s*[:~]' end='\ze\n\{2,}[^:~\u0020\u0009]'
    \ contains=HWEmoji,HWKeyword,@CHWLink,@CHWInlineCM,@CHWTextDeclaration,@CHWInlineTag,HWItalic,
    \   HWReference,HWCodeBlock,HWMathBlock,HWList,@CHWTagBlock,
    \   HWDefineHead,HWDefineContent,
    \   @CHWOthersInline
syn match HWDefineHead '^[^:~\u0020\u0009].*$' contained keepend
    \ contains=HWEmoji,HWKeyword,@CHWLink,@CHWInlineCM,@CHWTextDeclaration,@CHWInlineTag
syn region HWDefineContent matchgroup=HWDefineContentDelimiter contained keepend
    \ start='^\s*[:~]\s\+' end='\ze\n\s*[:~]\s\+'
    \ contains=HWEmoji,HWKeyword,@CHWLink,@CHWInlineCM,@CHWTextDeclaration,@CHWInlineTag,
    \   HWReference,HWCodeBlock,HWMathBlock,HWList,@CHWTagBlock,
    \   @CHWOthersInline

"+-------------------------------------------------------------------------------------+
"|                                    \ Highlight /                                    |
"+-------------------------------------------------------------------------------------+

"---------------------------------------\ Header /--------------------------------------
hi link HWHeader Define

"------------------------------\ Original link or image /------------------------------
hi HWRawLink cterm=underline gui=underline
hi link HWLink HWRawLink
hi link HWHtmlLink HWRawLink

"--------------------------------------\ Heading /--------------------------------------
hi HWHeading1 cterm=bold gui=bold ctermfg=9  guifg=#e08090
hi HWHeading2 cterm=bold gui=bold ctermfg=10 guifg=#80e090
hi HWHeading3 cterm=bold gui=bold ctermfg=12 guifg=#6090e0
hi HWHeading4 cterm=bold gui=bold ctermfg=15 guifg=#c0c0f0
hi HWHeading5 cterm=bold gui=bold ctermfg=15 guifg=#d5d5d5
hi HWHeading6 cterm=bold gui=bold ctermfg=15 guifg=#f9f9f9
hi HWLine     cterm=bold gui=bold ctermfg=59 guifg=#5C6370

hi HWH1Delimiter ctermfg=204 guifg=#dddddd
hi HWH2Delimiter ctermfg=204 guifg=#dddddd
hi HWH3Delimiter ctermfg=204 guifg=#dddddd
hi HWH4Delimiter ctermfg=204 guifg=#dddddd
hi HWH5Delimiter ctermfg=204 guifg=#dddddd
hi HWH6Delimiter ctermfg=204 guifg=#dddddd

"-------------------------------------\ Reference /-------------------------------------
hi HWReference ctermfg=59 guifg=#5C6370
hi HWReferenceHead ctermfg=59 guifg=#5C6370

"--------------------------------------\ Comment /--------------------------------------
hi link HWComment Comment

"-------------------------------------\ Code Block /------------------------------------
hi HWInlineCode cterm=italic gui=italic ctermfg=114 guifg=#98C379
hi HWCodeBlock  ctermfg=114 guifg=#98C379
hi HWCodeDelimiter cterm=italic gui=italic ctermfg=114 guifg=#98C379

"----------------------------------------\ Math /---------------------------------------
hi HWInlineMath ctermfg=180 guifg=#E5C07B
hi HWMathBlock  ctermfg=180 guifg=#E5C07B

"---------------------------------------\ Emoji /---------------------------------------
hi HWEmoji cterm=standout gui=standout

"----------------------------------------\ Abbr /---------------------------------------
hi HWAbbrHead cterm=bold,underline gui=bold,underline

"---------------------------------------\ Footer /--------------------------------------
hi HWFooter       cterm=bold,underline gui=bold,underline
hi HWFooterAnchor cterm=italic,underline gui=italic,underline

"----------------------------------\ Text declaration /---------------------------------
hi HWSub cterm=italic gui=italic
hi HWSup cterm=italic gui=italic
hi HWInsert cterm=underline gui=underline
hi HWDelete cterm=strikethrough gui=strikethrough
hi HWItalic cterm=italic gui=italic
hi HWBold cterm=bold gui=bold
hi HWItalicBold cterm=italic,bold gui=italic,bold
hi HWHighlight cterm=standout gui=standout

"---------------------------------------\ Define /--------------------------------------
hi HWDefineHead cterm=bold gui=bold
hi link HWDefineContent Comment

"---------------------------------------\ lists /---------------------------------------
hi HWList ctermfg=204 guifg=#E06C75

"------------------------------------\ Tags plugin /------------------------------------
hi HWTag cterm=italic,underline gui=italic,underline
hi link HWTagCodeBlock HWCodeBlock
hi link HWTagPostLink HWRawLink

"--------------------------------------\ Keywords /-------------------------------------
hi link HWKeyword Keyword

"+-------------------------------------------------------------------------------------+
"|                                     \ Others /                                      |
"+-------------------------------------------------------------------------------------+
syn match HWHtmlBr '<br/\?>' conceal cchar=⤶      " ⤶↩↵
hi link HWHtmlBr Comment

hi link HWEscape Comment

syn cluster CHWOthersInline contains=HWHtmlBr,HWEscape,HWFooterAnchor

hi SpellBad gui=undercurl

let b:current_syntax = 'markdown'
