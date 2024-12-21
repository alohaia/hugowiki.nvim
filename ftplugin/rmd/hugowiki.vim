" Vim plugin for writing hugo posts
" Maintainer: Qihuan Liu <liu.qihuan@outlook.com>

exec 'source ' . globpath(&rtp, "ftplugin/markdown/hugowiki.vim")

if g:hugowiki_rmd_auto_knit.enable && match(expand("%:p"), g:hugowiki_home) != -1
    au BufWritePost <buffer> lua require'hugowiki'.rmd_writepost()
endif
