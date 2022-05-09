" Vim plugin for writing hugo posts
" Maintainer: Qihuan Liu <liu.qihuan@outlook.com>

if exists('b:did_hugowiki')
    let g:hugowiki_info = "[markdown/hugowiki.vim] b:did_ftplugin: " . b:did_ftplugin
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

if !hasmapto('<Plug>FollowLinkN')
    nmap <buffer> <CR> <Plug>FollowLinkN
endif
if !hasmapto('<Plug>FollowLinkV')
    xmap <buffer> <CR> <Plug>FollowLinkV
end
if !hasmapto('<Plug>FindLinkP')
    nmap <buffer> <S-Tab> <Plug>FindLinkP
endif
if !hasmapto('<Plug>FindLinkN')
    nmap <buffer> <Tab> <Plug>FindLinkN
endif
if !hasmapto('<Plug>ShiftTitlesInc')
    nmap <nowait> <buffer> <Leader>>> <Plug>ShiftTitlesInc
endif
if !hasmapto('<Plug>ShiftTitlesDec')
    nmap <nowait> <buffer> <leader><< <Plug>ShiftTitlesDec
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

if g:hugowiki_rmd_auto_knit.enable
    au BufWritePost <buffer> lua require'hugormd'.rmd_writepost()
endif
