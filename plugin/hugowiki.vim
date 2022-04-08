" Vim plugin for writing hugo posts
" Maintainer: Qihuan Liu <liu.qihuan@outlook.com>

if exists('g:loaded_hugowiki') || &compatible
  finish
endif
let g:loaded_hugowiki = 1

" prepare configs
let g:hugowiki_home = get(g:, 'hugowiki_home')
let g:hugowiki_home =
    \ strgetchar(g:hugowiki_home, strlen(g:hugowiki_home)-1) == 47
    \ ? g:hugowiki_home[:-2] : g:hugowiki_home

let g:hugowiki_try_init_file = get(g:, 'hugowiki_try_init_file', 0)
let g:hugowiki_follow_after_create = get(g:, 'hugowiki_follow_after_create', 0)
let g:hugowiki_use_imaps = get(g:, 'hugowiki_use_imaps', 1)
let g:hugowiki_disable_fold = get(g:, 'hugowiki_disable_fold', 0)
let g:hugowiki_wrap = get(g:, 'hugowiki_wrap', 1)
let g:hugowiki_auto_save = get(g:, 'hugowiki_auto_save', 1)
let g:hugowiki_auto_update_lastmod = get(g:, "hugowiki_auto_update_lastmod", 1)
let g:hugowiki_lastmod_under_date = get(g:, "hugowiki_auto_update_lastmod", 1)

function! g:hugowiki#at_home()
    return match(expand("%:p:h").'/', expand(g:hugowiki_home).'/') == 0
endfunction

function! s:is_ascii(pos)
    let line = getline('.')
    if and(char2nr(line[col(a:pos)-1]), 0x80) == 0
        return v:true
    else
        return v:false
    endif
endfunction

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

" Get inline visual selection.
"
" Return:
"   - a list descripting selection
"       0: String, selection string
"       1: int, begin position
"       2: int, end porition
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

" Create a new link under the cursor.
"
" Return:
"   - Empty string if failed.
"   - Name of new file (should be used by s:getFile) if Succeed.
function! s:createLink(mode)
    let line = getline('.')
    let col = col('.') - 1

    if char2nr(line[col]) == 32 || char2nr(line[col]) == 9 || char2nr(line[col]) == 0
        " echo '[hugowiki.vim] Not on any valid text, cannot create a link here.'
        return ''
    endif

    if a:mode == 'v' || a:mode == 'V'   " Visual mode
        let visual_selection = s:visualInline()
        let base = visual_selection[0]
        " echo visual_selection
        if visual_selection[1] == 0
            let newline = '[' . visual_selection[0] . ']({{< relref "'
                        \ . visual_selection[0] . '" >}})'
                        \ . line[visual_selection[2]+1 :]
        else
            let newline = line[: visual_selection[1]-1] . '[' . visual_selection[0]
                        \ . ']({{< relref "' . visual_selection[0] . '" >}})'
                        \ . line[visual_selection[2]+1 :]
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
            let newline = '[' . base . ']({{< relref "' . base. '" >}})' . line[matchn :]
        else
            let newline = line[: matchp-1] . '[' . base . ']({{< relref "' . base. '" >}})' . line[matchn :]
        endif
    endif

    call setline(line('.'), newline)
    return base
endfunction

function! s:createFile() abort
    " if file doesn't exist and cwd is the right dir
    if glob(expand('%:p')) == '' && expand('%:p:h') == expand(g:hugowiki_home)
        echo '[hugowiki.vim] hugo new "' . expand('%:t:r') . '" ...'
        call system('hugo new "' . expand('%:t:r') . '"')
        edit
    endif
endfunction


const s:subfixes = ['.Rmd', '.md', '/index.md', '/_index.md']

function! s:getFile(s)
    let file_path = ""
    if a:s[0] == "/"
        let file_path = g:hugowiki_home . "/content" . a:s
    elseif match(file_path, "/") != -1
        let file_path = expand("%:p:h") . "/" . a:s
    else
        " ".*/病原生物学"
        let file_list = system('find ' . g:hugowiki_home . '/content -regex ".*/' . a:s . '\(/_?index.md\|.md\)"')
        let file_list = split(file_list, "\n")
        if len(file_list) != 1
            return ""
        else
            return file_list[0]
        endif
    endif

    if match(file_path, "\\(" . join(s:subfixes, "$\\|") . "\\)") != -1
        return file_path
    else
        for subfix in s:subfixes
            let full_path = glob(file_path . subfix)
            if full_path != ""
                let file_path = full_path
                return full_path
            endif
        endfor
    endif

    return ""
endfunction


function! s:jumpToAnchor(a, flags)
    let anc = tolower(substitute(a:a[1:], '-', '[ -]', 'g'))
    if !search('^#\+\s\+' . anc . '\(\s*{.*}\)\?$'
        \ . '\|^#\+\s\+.*{.*\<\(alias\|id\)="[^"]*\<' . anc . '\>[^"]*".*}$'
        \ . '\|^#\+\s\+.*{.*\<\(alias\|id\)=''[^'']*\<' . anc . '\>[^'']*''.*}$'
        \ . '\|^#\+\s\+.*{.*#' . anc . '.*}$', a:flags)
        return v:false
    else
        call search(anc)
        return v:true
    endif
endfunction


const s:link_patterns = [
    \ '\\\@<!\[\(\^.\{-}\)\\\@<!\]:\@<!',
    \ '\\\@<!\[.\{-}\\\@<!\]({{<\s*\(rel\)\?ref\s\+"\([^#]\{-}\)\(#.\{-}\)\?"\s\+>}}\\\@<!)',
    \ '\\\@<!\[.\{-}\\\@<!\](\(#.\{-}\)\\\@<!)',
    \ '\\\@<!\[.\{-}\\\@<!\](\(.\{-}\)\\\@<!)'
    \ ]

" Create or follow ori_link link
function! s:followLink() abort
    let line = getline('.')
    let col = col('.') - 1

    let link_type = -1
    let matchb = 0
    let matche = 0
    " If cursor is on a link, get the beginning, end and type of the link.
    for link_type in range(len(s:link_patterns))
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
            " echo '[hugowiki.vim] Fonud: ' . line[matchb : matche-1]
            break
        else
            " Not Found
            " echo '[hugowiki.vim] not link type ' . link_type . ': ' matchb
            let matchb = 0
            let matche = 0
        endif
    endfor

    " echo '[hugowiki.vim] link type: ' . link_type . "\n" . 'matchb: ' . matchb

    " No link in current line
    if matchb == 0 && matche == 0
        " Create a link under cursor
        let new_file = s:createLink(mode())
        if g:hugowiki_follow_after_create
            if s:getFile(new_file) != ''
                execute 'edit ' . expand("%:p:h") . '/' . s:getFile(new_file)
            elseif new_file != ''
                execute 'edit ' . new_file
            endif
        endif
    else    " follow link
        let m = matchlist(line[matchb:matche-1], s:link_patterns[link_type])
        if link_type == 0
            call search('^\[' . m[1] . '\\\@<!\]:\s', 's')
        elseif link_type == 1
            let file_path = s:getFile(m[2])
            if file_path != ''
                execute 'edit ' . file_path
                if m[3] != ''
                    if !s:jumpToAnchor(m[3], '')
                        echo '[hugowiki.vim] Anchor ' . m[3] . ' not found.'
                    end
                end
            else
                echo '[hugowiki.vim] File not exists or multiple files match.'
            endif
        elseif link_type == 2
            call s:jumpToAnchor(m[1], 's')
        elseif link_type == 3
            call system('xdg-open ' . m[1])
            echo '[hugowiki.vim] xdg-open ' . m[1]
        endif
    endif

endfunction

function! s:findLink(foreward)
    call searchpos(join(s:link_patterns, '\|'), a:foreward ? 'sb' : 's')
endfunction

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
    " if syn_name == 'HWTagDelimiter'
    "     let name_pattern = '\('.join(g:hugowiki_multiline_tags_with_end, '\|').'\)'
    "     if getline(a:lnum) =~# '^{%\s\+' . name_pattern . '.*%}'
    "         return 'a1'
    "     elseif getline(a:lnum) =~# '^{%\s\+end' . name_pattern . '\s\+%}'
    "         return 's1'
    "     end
    " endif

    " Code Block
    if syn_name =~# 'HWCodeDelimiterStart.*'
        return 'a1'
    endif
    if syn_name =~# 'HWCodeDelimiterEnd.*'
        return 's1'
    endif

    " Header
    if syn_name == 'HWHeaderDelimiter'
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

function! g:hugowiki#UpdateModTime()
    let now = system('date +%Y-%m-%dT%T%:z')[0:-2]
    let header_end = searchpos('\n\zs---', 'n')
    let date_pos = searchpos('^date: ', 'n')[0]
    let pos = searchpos('^lastmod:', 'n')
    let save_cursor = getpos(".")

    if date_pos[0] > header_end[0]
        date_pos[0] = header_end[0] - 1
    endif

    if pos[0] != 0 && pos[0] < header_end[0] " already have lastmod setted
        call setline(pos[0], 'lastmod: ' . now)
        if g:hugowiki_lastmod_under_date == 1 && pos[0] != date_pos[0]+1
            execute pos[0] . 'move ' . date_pos[0]
        endif
    else
        if g:hugowiki_lastmod_under_date == 1
            call append(date_pos, 'lastmod: ' . now)
        else
            call append(header_end[0]-1, 'lastmod: ' . now)
        endif
    endif

    call setpos('.', save_cursor)
endfunction

function! s:newDiary()
    let relpath = 'content/diary/' . strftime('%Y/%m/%d') . '/index.md'
    if glob(expand([g:hugowiki_home, relpath]->join('/'))) == ''
        call system(['hugo -s', g:hugowiki_home, 'new', relpath]->join(' '))
        echo '[hugowiki.vim] content/diary/' . strftime('%Y/%m/%d') . '/index.md created.'
    else
        echo '[hugowiki.vim] content/diary/' . strftime('%Y/%m/%d') . '/index.md already exists.'
    endif
    exec 'edit' g:hugowiki_home .. '/' .. relpath
endfunction


noremap <unique> <SID>FollowLinkN <Cmd>call <SID>followLink()<CR>
noremap <unique> <SID>FollowLinkV <ESC>gv<Cmd>call <SID>followLink()<CR><ESC>
noremap <unique> <SID>FindLinkP <Cmd>call <SID>findLink(1)<CR>
noremap <unique> <SID>FindLinkN <Cmd>call <SID>findLink(0)<CR>
noremap <unique> <SID>ShiftTitlesInc <Cmd>call <SID>shiftTitles(1)<CR>
noremap <unique> <SID>ShiftTitlesDec <Cmd>call <SID>shiftTitles(0)<CR>

noremap <unique><script> <Plug>HWFollowLinkN <SID>FollowLinkN
noremap <unique><script> <Plug>HWFollowLinkV <SID>FollowLinkV
noremap <unique><script> <Plug>HWFindLinkP <SID>FindLinkP
noremap <unique><script> <Plug>HWFindLinkN <SID>FindLinkN
noremap <unique><script> <Plug>HWShiftTitlesDec <SID>ShiftTitlesDec
noremap <unique><script> <Plug>HWShiftTitlesInc <SID>ShiftTitlesInc

command HWNewDiary call <SID>newDiary()

function! g:hugowiki#Conv()
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
    %s/\(\s*- .*\)：$/\1/g
    %s/date: \(\S\+\) \(\S\+\)/date: \1T\2+08:00
    " sub ?
endfunction

