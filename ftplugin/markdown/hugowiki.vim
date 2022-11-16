" Vim plugin for writing hugo posts
" Maintainer: Qihuan Liu <liu.qihuan@outlook.com>

if exists('b:did_hugowiki')
    finish
elseif &compatible
    echoerr "Only support Nvim."
    finish
endif
let b:did_hugowiki = 1

if g:hugowiki_disable_fold == 0
    setlocal foldmethod=expr
    setlocal foldexpr=hugowiki#foldexpr(v:lnum)
    setlocal foldtext=hugowiki#foldtext()
endif

if g:hugowiki_wrap == 1
    setlocal wrap
endif

if !hasmapto('<Plug>HWFollowLinkN')
    nmap <buffer> <CR> <Plug>HWFollowLinkN
endif
if !hasmapto('<Plug>HWFollowLinkV')
    xmap <buffer> <CR> <Plug>HWFollowLinkV
end
if !hasmapto('<Plug>HWFindLinkP')
    nmap <buffer> <C-,> <Plug>HWFindLinkP
endif
if !hasmapto('<Plug>HWFindLinkN')
    nmap <buffer> <C-.> <Plug>HWFindLinkN
endif
if !hasmapto('<Plug>HWShiftTitlesInc')
    nmap <nowait><buffer> <Leader>>> <Plug>HWShiftTitlesInc
endif
if !hasmapto('<Plug>HWShiftTitlesDec')
    nmap <nowait><buffer> <leader><< <Plug>HWShiftTitlesDec
endif

if g:hugowiki_use_imaps == 1
    inoremap <buffer><unique> <expr> ： col('.') == 1 ? ': ' : '：'
    inoremap <buffer><unique> <expr> :  col('.') == 1 ? ': ' : ':'
    inoremap <buffer><unique> <expr> 》 col('.') == 1 ? '> ' : '》'
    inoremap <buffer><unique> <expr> >  match(getline('.')[0:col('.')-1], '[^ >]') == -1 ? '> ' : '\>'
    inoremap <buffer><unique> ~ \~
    inoremap <buffer><unique> * \*
    inoremap <buffer><unique> < \<
endif

if g:hugowiki_auto_update_lastmod == 1 && g:hugowiki#at_home() == 1
    au BufWrite <buffer> call g:hugowiki#UpdateModTime()
endif

if g:hugowiki_auto_save
    augroup autosave
        au!
        au InsertLeave <buffer> silent update
    augroup END
endif

command! HWConv call g:hugowiki#Conv()

nnoremap <C-1> <Cmd>call g:hugowiki#changeHeadingLevel(1)<CR>
nnoremap <C-2> <Cmd>call g:hugowiki#changeHeadingLevel(2)<CR>
nnoremap <C-3> <Cmd>call g:hugowiki#changeHeadingLevel(3)<CR>
nnoremap <C-4> <Cmd>call g:hugowiki#changeHeadingLevel(4)<CR>
nnoremap <C-5> <Cmd>call g:hugowiki#changeHeadingLevel(5)<CR>
nnoremap <C-6> <Cmd>call g:hugowiki#changeHeadingLevel(6)<CR>
