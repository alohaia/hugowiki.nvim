" Vim plugin for writing hugo posts
" Maintainer: Qihuan Liu <liu.qihuan@outlook.com>

if exists("b:did_ftplugin_rmd_hugowiki")
  finish
elseif &compatible
    echoerr "Only support Nvim."
    finish
endif
let b:did_ftplugin_rmd_hugowiki = 1

exec 'source ' . globpath(&rtp, "ftplugin/markdown/hugowiki.vim")

if g:hugowiki_rmd_auto_knit.enable && match(expand("%:p"), g:hugowiki_home) != -1
    augroup hugowiki_knit_rmarkdown
        au!
        au BufWritePost <buffer> lua require'hugowiki'.rmd_writepost()
    augroup END
endif
