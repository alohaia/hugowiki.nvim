" Vim plugin for writing hugo posts
" Maintainer: Qihuan Liu <liu.qihuan@outlook.com>

" echomsg "Load rmd/hugowiki.vim"
" echomsg "Current g:hugowiki_home: " . g:hugowiki_home

exec 'source ' . globpath(&rtp, "ftplugin/markdown/hugowiki.vim")

if g:hugowiki_rmd_auto_knit.enable && match(expand("%:p"), g:hugowiki_home) != -1
    au BufWritePost <buffer> lua require'hugowiki'.rmd_writepost()
endif
