" Vim plugin for writing hugo posts
" Maintainer: Qihuan Liu <liu.qihuan@outlook.com>

if exists('g:loaded_hugowiki') || &compatible
  finish
endif
let g:loaded_hugowiki = 1

"---------------------------------------\ config /---------------------------------------
let g:hugowiki_home = get(g:, 'hugowiki_home')
let g:hugowiki_home =
    \ strgetchar(g:hugowiki_home, strlen(g:hugowiki_home)) == '/'
    \ ? g:hugowiki_home[:-2] : g:hugowiki_home

let g:hugowiki_try_init_file = get(g:, 'hugowiki_try_init_file', 0)
let g:hugowiki_follow_after_create = get(g:, 'hugowiki_follow_after_create', 0)
let g:hugowiki_use_imaps = get(g:, 'hugowiki_use_imaps', 1)
let g:hugowiki_disable_fold = get(g:, 'hugowiki_disable_fold', 0)
let g:hugowiki_header_items = get(g:, 'hugowiki_header_items', [
    \ 'title', 'comments', 'mathjax', 'date',
    \ 'tags', 'categories', 'coauthor'
    \ ])
let g:hugowiki_wrap = get(g:, 'hugowiki_wrap', 1)
let g:hugowiki_auto_save = get(g:, 'hugowiki_auto_save', 1)

"---------------------------------\ initialize a file /----------------------------------
function! s:is_ascii(pos)
    let line = getline('.')
    if and(char2nr(line[col(a:pos)-1]), 0x80) == 0
        return v:true
    else
        return v:false
    endif
endfunction

" get the number of bytes of a character according to its first byte
" get the number of bytes of a character according to its first byte
function! s:wcharlen(charfb)
    let cmasks = [0x80, 0xe0, 0xf0, 0xf8, 0xfc, 0xfe]
    let cvals  = [0x00, 0xc0, 0xe0, 0xf0, 0xf8, 0xfc]
    let char_nr = char2nr(a:charfb)
    for i in range(6)
        if and(char_nr, cmasks[i]) == cvals[i]
            return i+1
        endif
    endfor
endfunction

function! s:visualInline()
    let line = getline('.')

    let vbegin = col("v") - 1
    let vend   = col(".") - 1
    if vbegin > vend
        let t = vend
        let vend = vbegin
        let vbegin = t
    endif

    " adjusts vend if it's not refering an ASCII character
    if and(char2nr(line[vend]), 0x80) != 0
        let vend += s:wcharlen(getline('.')[vend]) - 1
    endif

    return [getline('.')[vbegin:vend], vbegin, vend]
endfunction

" Create a new link under the cursor
"
" Return:
"   - Empty string if failed.
"   - Name of new file if Succeed.
function! s:createLink(mode)
    let line = getline('.')
    let col = col('.') - 1

    if char2nr(line[col]) == 32 || char2nr(line[col]) == 9 || char2nr(line[col]) == 0
        " echo 'Not on any valid text, cannot create a link here.'
        return ''
    endif

    if a:mode == 'v' || a:mode == 'V'
        " Visual mode
        let visual_selection = s:visualInline()
        let base = visual_selection[0]
        echo visual_selection
        if visual_selection[1] == 0
            let newline = '<a href="{% post_path ' . substitute(visual_selection[0], '\s', '-', 'g') . ' %}">' .
                        \ visual_selection[0] . '</a>' . line[visual_selection[2]+1 :]
        else
            let newline = line[: visual_selection[1]-1] . '<a href="{% post_path ' . substitute(visual_selection[0], '\s', '-', 'g') . ' %}">' .
                        \ visual_selection[0] . '</a>' . line[visual_selection[2]+1 :]
        endif
    else
        let matchp = match(line, '\S')
        let matchn = match(line, '\s', matchp)
        while matchp > col || matchn <= col
            let matchp = match(line, '\S', matchn)
            let matchn = match(line, '\s', matchp)
            if matchn == -1
                let matchn = strlen(line) + 1
            endif
        endwhile

        let base = line[matchp : matchn - 1]
        if matchp == 0
            let newline = '<a href="{% post_path ' . base . ' %}">' . base. '</a>' . line[matchn :]
        else
            let newline = line[: matchp-1] . '<a href="{% post_path ' . base . ' %}">' . base. '</a>' . line[matchn :]
        endif
    endif

    call setline(line('.'), newline)
    return base != '' ? base . '.md' : ''
endfunction

function! s:init_file() abort
    " if file doesn't exist and file is in right dir
    if glob(expand('%:p')) == '' && expand('%:p:h') == expand(g:hugowiki_home)
        " TODO: detect page type
        let l:type = 'post'

        echo 'hugo new ' . l:type . ' "' . expand('%:t:r') . '" ...'
        call system('hugo new ' . l:type . ' "' . expand('%:t:r') . '"')
        edit
    endif
endfunction

let s:link_patterns = [
    \ '{%\s*post_link\s\+.\{-1,}%}',
    \ '<a\s\+href=[''"]{%\s\+post_path\s\+\(.\{-1,}\)\s*%}\(?highlight=.\{-}\)\=\(#.\{-}\)\=[''"]>.\{-}<\/a>',
    \ '\[.\{-1,}\](\(?highlight=.\{-}\)*\(#.\{-1,}\))',
    \ '!\?\[.\{-1,}\](\(.\{-1,}\))',
    \ '\[\(\^.\{-}\)\]\(:\=\)'
    \ ]

" Create or follow ori_link link
function! s:followLink() abort
    let line = getline('.')
    let col = col('.') - 1

    let link_type = -1
    let matchb = 0
    let matche = 0
    " If cursor is on a link, get the beginning, end and type of the link.
    for link_type in range(5)
        " let matchb = match(line, s:link_patterns[link_type])
        " " No link in this line
        " if matchb == -1
        "     continue
        " endif
        " let matche = matchend(line, s:link_patterns[link_type])
        "
        " When the cursor is not on current link, try to find next link.
        while (col < matchb || col >= matche) && matchb != -1
            let matchb = match(line, s:link_patterns[link_type], matche)
            if matchb == -1
                " Try another link type
                break
            endif
            let matche = matchend(line, s:link_patterns[link_type], matchb)
        endwhile


        if matchb != -1
            " Found
            " echo 'Fonud: ' . line[matchb : matche-1]
            break
        else
            " Not Found
            " echo 'not link type ' . link_type . ': ' matchb
            let matchb = 0
            let matche = 0
        endif
    endfor

    " echo 'link type: ' . link_type . "\n" . 'matchb: ' . matchb

    " No link in current line
    if matchb == 0 && matche == 0
        " Create a link under cursor
        let new_file = s:createLink(mode())
        if new_file != '' && g:hugowiki_follow_after_create
            execute 'edit ' . new_file
        endif
    " Jump somewhere according to `link_type`
    elseif link_type == 0
        " Go to the the file specified by the link.
        let match_list = matchlist(line[matchb : matche-1], '{%\s*post_link\s\+\([^\u0020\u0009]\+\).\{-1,}%}')
        execute 'edit ' . g:hugowiki_home . match_list[1] . '.md'
        if g:hugowiki_try_init_file == 1
            call s:init_file()
        endif
    elseif link_type == 1
        let m = matchlist(line[matchb:matche-1], s:link_patterns[link_type])
        execute 'edit ' . m[1] . '.md'
        if g:hugowiki_try_init_file == 1
            call s:init_file()
        endif
        if m[3] != '#' && m[3][0] == '#'
            call search('#\+\s\+' . tolower(substitute(m[3][1:], '-', '[ -]', 'g')) . '$')
        endif
    elseif link_type == 2
        let m = matchlist(line[matchb:matche-1], s:link_patterns[link_type])
        " echo tolower(substitute(m[2][1:], '-', ' ', 'g'))
        if !search('#\+\s\+' . tolower(substitute(m[2][1:], '-', '[ -]', 'g')) . '$', 's')
            if !search('{%\stabs\s' . tolower(substitute(m[2][1:], '-', '[ -]', 'g')) . ',\d\s%}', 's')
                echo 'Anchor ' . m[2][1:] . ' not found.'
            endif
        endif
    elseif link_type == 3
        let m = matchlist(line[matchb:matche-1], s:link_patterns[link_type])
        call system('xdg-open ' . m[1])
    elseif link_type == 4
        let m = matchlist(line[matchb:matche-1], s:link_patterns[link_type])
        if m[2] == ''
            call search('^\[' . m[1] . '\]:\s', 's')
        else
            call search('\[' . m[1] . '\]\($\|[^:]\)', 'sb')
        endif
    endif

endfunction

function! s:findLink(foreward)
    call searchpos(join(s:link_patterns, '\|'), a:foreward ? 'sb' : 's')
endfunction

"--------------------------------------\ folding /--------------------------------------
function! g:hugowiki#foldexpr(lnum)
    let syn_name = synIDattr(synID(a:lnum, match(getline(a:lnum), '\S') + 1, 1), "name")
    let syn_name_eol = synIDattr(synID(a:lnum, match(getline(a:lnum), '\S\s*$')+1, 1), "name")

    " Heading
    if syn_name =~# 'HWH[1-6]Delimiter'
        if search('^#\s', 'n')
            return '>' .. matchstr(syn_name, '\d')
        else
            return '>' .. (matchstr(syn_name, '\d') - 1)
        endif
    endif

    " List TODO: simple method
    " if syn_name == 'HWList'
    "     let pline = getline(a:lnum - 1)
    "     let nline = getline(a:lnum + 1)
    "     let syn_name_pre = synIDattr(synID(a:lnum - 1, match(pline, '\S') + 1, 1), "name")
    "     let syn_name_nxt = synIDattr(synID(a:lnum + 1, match(nline, '\S') + 1, 1), "name")
    "
    "     let change = strdisplaywidth(match(pline, '\S')) - strdisplaywidth(match(getline(a:lnum), '^\s\+'))
    "     echo change
    "
    "     if syn_name_pre == 'HWList'
    "     endif
    "     return 'a1'
    " endif

    " hugo tag
    if syn_name == 'HWTagDelimiter'
        let name_pattern = '\('.join(g:hugowiki_multiline_tags_with_end, '\|').'\)'
        if getline(a:lnum) =~# '^{%\s\+' . name_pattern . '.*%}'
            return 'a1'
        elseif getline(a:lnum) =~# '^{%\s\+end' . name_pattern . '\s\+%}'
            return 's1'
        end
    endif

    " Code Block
    if syn_name =~# 'HWCodeDelimiterStart.*'
        return 'a1'
    endif
    if syn_name =~# 'HWCodeDelimiterEnd.*'
        return 's1'
    endif

    " Header
    if syn_name == 'HWHeader'
        if a:lnum == 1
            return 'a1'
        else
            return 's1'
        endif
    endif

    " Math Block
    if syn_name == 'HWMathDelimiterStart'
        return 'a1'
    endif
    if syn_name_eol == 'HWMathDelimiterEnd'
        return 's1'
    endif

    " default
    return '='
endfunction

function! g:hugowiki#foldtext() abort
    let syn_name = synIDattr(synID(v:foldstart, match(getline(v:foldstart), '\S')+1, 1), "name")
    if syn_name == 'HWHeader'
        let line = substitute(getline(v:foldstart + 1), '^\w*: ', '', '')
    else
        let line = getline(v:foldstart)
    endif
    let head = '+' . v:foldlevel . '··· ' . (v:foldend-v:foldstart+1) 
        \ . '(' . v:foldstart . ':' . v:foldend . ') lines: '
        \ . trim(substitute(line, '{%\|%}\|`\|^#\+', '', 'g')) . ' '
    return head
endfunction

"------------------------------------\ Shift titles /-----------------------------------
function! s:shiftTitles(inc)
    let line = getline('.')
    if line !~ '^#\+\s\+.*$'
        return
    endif
    let lev = strlen(matchstr(line, '^#\+'))
    call setline('.', a:inc
                \ ? '#' . line
                \ : line[1:]
                \ )
    " shift other headings
    let curpos = getcurpos()
    let stopln = searchpos('^#\{1,' . lev . '}\s', 'nW')[0]
    let stopln = stopln == 0 ? 0 : stopln - 1
    let ln = -1
    while ln != 0
        let ln = searchpos('^#\{' . (lev+1) . '}', 'W', stopln)[0]
        let line = getline(ln)
        call setline(ln, a:inc
                    \ ? '#' . line
                    \ : line[1:]
                    \ )
    endwhile
    call cursor(curpos[1], curpos[2])
endfunction

"--------------------------------------\ mappings /-------------------------------------
noremap <unique><script> <Plug>FollowLinkN <SID>FollowLinkN
noremap <unique><script> <Plug>FollowLinkV <SID>FollowLinkV
noremap <unique><script> <Plug>FindLinkP <SID>FindLinkP
noremap <unique><script> <Plug>FindLinkN <SID>FindLinkN

noremap <unique> <SID>FollowLinkN <cmd>call <SID>followLink()<CR>
noremap <unique> <SID>FollowLinkV <ESC>gv<cmd>call <SID>followLink()<CR><ESC>
noremap <unique> <SID>FindLinkP <cmd>call <SID>findLink(1)<CR>
noremap <unique> <SID>FindLinkN <cmd>call <SID>findLink(0)<CR>

noremap <unique><script> <Plug>ShiftTitlesInc <SID>ShiftTitlesInc
noremap <unique><script> <Plug>ShiftTitlesDec <SID>ShiftTitlesDec

noremap <unique> <SID>ShiftTitlesInc <Cmd>call <SID>shiftTitles(1)<CR>
noremap <unique> <SID>ShiftTitlesDec <Cmd>call <SID>shiftTitles(0)<CR>

"--------------------------------------\ autocmd /--------------------------------------
if g:hugowiki_auto_save
    augroup autosave
        au!
        au InsertLeave *.md,*.markdown,*.Rmd silent update
        au TextChanged *.md,*.markdown,*.Rmd silent update
    augroup END
endif

function! g:Conv()
    %s/{\@<!{%/{{%/g
    %s/%}}\@!/%}}/g
    %s/++\(.\{-}\)++/<ins>\1<\/ins>/g
    %s/==\(.\{-}\)==/<mark>\1<\/mark>/g
    %s/<a href="{{% post_path \(\S*\) %}}\(.\{-}\)">\(.\{-}\)<\/a>/[\3]({{< relref "\1\2" >}})/g
    %s/?highlight=.\{-}"/"/g
    %s/{{% note/{{% tab/g
    %s/{{% endnote/{{% \/tab/g
    %s/{{% end\(\S*\) %}}/{{% \/\1 %}}/g
    %s/endhzl/\/hzl/g
    %s/hzl \(\S\) %}}/hzl "\1" %}}/g
    %s/\^\(.\{-}\)\^/<sup>\1<\/sup>/g
    %s/\(\\\|\~\)\@<!\~\([^~ ]\{1,}\)\~\~\@!/<sub>\2<\/sub>/g
    " sub ?
endfunction

