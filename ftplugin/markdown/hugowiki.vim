" Vim plugin for writing hugo posts
" Maintainer: Qihuan Liu <liu.qihuan@outlook.com>

if exists('b:did_ftplugin_markdown_hugowiki')
    finish
elseif &compatible
    echoerr "Only support Nvim."
    finish
endif
let b:did_ftplugin_markdown_hugowiki = 1

" prepare configs
let g:hugowiki_home = get(g:, 'hugowiki_home')
" remove tailing /
if g:hugowiki_home =~ '/$'
    let g:hugowiki_home = g:hugowiki_home[:-2]
endif

let g:hugowiki_try_init_file = get(g:, 'hugowiki_try_init_file', 0)
let g:hugowiki_follow_after_create = get(g:, 'hugowiki_follow_after_create', 0)
let g:hugowiki_use_imaps = get(g:, 'hugowiki_use_imaps', 1)
let g:hugowiki_disable_fold = get(g:, 'hugowiki_disable_fold', 0)
let g:hugowiki_wrap = get(g:, 'hugowiki_wrap', 1)
let g:hugowiki_auto_save = get(g:, 'hugowiki_auto_save', 1)
let g:hugowiki_auto_update_lastmod = get(g:, "hugowiki_auto_update_lastmod", 1)
let g:hugowiki_lastmod_under_date = get(g:, "hugowiki_lastmod_under_date", 1)
let g:hugowiki_spellcheck_ignore_upcase = get(g:, "hugowiki_spellcheck_ignore_upcase", 1)
let g:hugowiki_snippy_integration = get(g:, "hugowiki_snippy_integration", 0)

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
" if !hasmapto('<Plug>HWFindLinkP')
"     nmap <buffer> <C-,> <Plug>HWFindLinkP
" endif
" if !hasmapto('<Plug>HWFindLinkN')
"     nmap <buffer> <C-.> <Plug>HWFindLinkN
" endif
if !hasmapto('<Plug>HWShiftTitlesInc')
    nmap <nowait><buffer> <Leader>>> <Plug>HWShiftTitlesInc
endif
if !hasmapto('<Plug>HWShiftTitlesDec')
    nmap <nowait><buffer> <Leader><< <Plug>HWShiftTitlesDec
endif
if !hasmapto('<Plug>HWPuncConv')
    nmap <nowait><buffer> <Leader>. mz<Plug>HWPuncConv`z
endif

if g:hugowiki_use_imaps == 1
    inoremap <buffer><unique> <expr> ： col('.') == 1 ? ': ' : '：'
    inoremap <buffer><unique> <expr> :  col('.') == 1 ? ': ' : ':'
    inoremap <buffer><unique> <expr> 》 col('.') == 1 ? '> ' : '》'
    inoremap <buffer><unique> <expr> >  match(getline('.')[0:col('.')-1], '[^ >]') == -1 ? '> ' : '>'
endif

if g:hugowiki_auto_update_lastmod == 1 && g:hugowiki#at_home() == 1
    execute "augroup update_lastmod_"..bufnr()
        au!
        au BufWrite <buffer> call g:hugowiki#UpdateModTime(bufnr())
    augroup END
endif

if g:hugowiki_auto_save
    augroup autosave
        au!
        au InsertLeave <buffer> silent update
    augroup END
endif

command! HWConv call g:hugowiki#Conv()

nnoremap <buffer> <C-1> <Cmd>call g:hugowiki#changeHeadingLevel(1)<CR>
nnoremap <buffer> <C-2> <Cmd>call g:hugowiki#changeHeadingLevel(2)<CR>
nnoremap <buffer> <C-3> <Cmd>call g:hugowiki#changeHeadingLevel(3)<CR>
nnoremap <buffer> <C-4> <Cmd>call g:hugowiki#changeHeadingLevel(4)<CR>
nnoremap <buffer> <C-5> <Cmd>call g:hugowiki#changeHeadingLevel(5)<CR>
nnoremap <buffer> <C-6> <Cmd>call g:hugowiki#changeHeadingLevel(6)<CR>

nnoremap <buffer> <C-,> "zs<sub><C-r>z</sub><ESC>l
nnoremap <buffer> <C-.> "zs<sup><C-r>z</sup><ESC>l
xnoremap <buffer> <C-,> "zc<sub><C-r>z</sub><ESC>l
xnoremap <buffer> <C-.> "zc<sup><C-r>z</sup><ESC>l
inoremap <buffer> <C-,> <ESC>"zs<sub><C-r>z</sub>
inoremap <buffer> <C-.> <ESC>"zs<sup><C-r>z</sup>

nnoremap <buffer> <leader>J mzjI<Backspace><ESC>`z

xnoremap <buffer> <C-b> "xc**<C-r>x**<ESC>
xnoremap <buffer> <C-i> "xc*<C-r>x*<ESC>
nnoremap <buffer> <C-b> "xciw**<C-r>x**<ESC>
nnoremap <buffer> <C-i> "xciw*<C-r>x*<ESC>
imap <buffer> *<C-b> <ESC>vb"xc**<C-r>x**
imap <buffer> *<C-i> <ESC>vb"xc*<C-r>x*
xnoremap <expr> <C-k> @+ =~? '^https\?://' ? '"zc[<C-r>z](<C-r>+)<ESC>' : '"zc[<C-r>z]()<Left>'
nnoremap <buffer> <M-h> "zciw{{< hdt "<C-r>z" >}}<ESC>
xnoremap <buffer> <M-h> "zc{{< hdt "<C-r>z" >}}<ESC>

nnoremap <buffer> <C-g> <Cmd>lua require'hugowiki'.get_ref("r")<CR>

