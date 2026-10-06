" Vim plugin for writing hugo posts
" Maintainer: Qihuan Liu <liu.qihuan@outlook.com>

if exists('b:current_syntax')
    echomsg "finished"
    finish
endif

runtime! syntax/markdown.vim
unlet! b:current_syntax

let b:current_syntax = 'rmd'
