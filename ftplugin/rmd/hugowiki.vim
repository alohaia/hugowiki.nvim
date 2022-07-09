" Vim plugin for writing hugo posts
" Maintainer: Qihuan Liu <liu.qihuan@outlook.com>

exec 'source ' . globpath(&rtp, "ftplugin/markdown/hugowiki.vim")

if g:hugowiki_rmd_auto_knit.enable
    au BufWritePost <buffer> lua require'hugormd'.rmd_writepost()
endif
