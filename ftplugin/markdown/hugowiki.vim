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

lua << END
local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local conf = require("telescope.config").values
local actions = require "telescope.actions"
local action_state = require "telescope.actions.state"
local themes = require("telescope.themes")

local nc = vim.fn.strcharlen

local content_path = vim.g.hugowiki_home .. '/content/'
local ext_pattern = [[\(/_\?index\)\?\.md$]]

local hw_pages = function(opts)
    opts = opts or themes.get_dropdown{
        layout_config = {
            width = 120,
            height = 30
        }
    }

    pickers.new(opts, {
        prompt_title = "Pages",
        finder = finders.new_table {
            results = vim.split(vim.trim(vim.fn.system('find ' .. content_path .. ' -name "*.md"')), '\n'),
            entry_maker = function(entry)
                local ref = entry:sub(content_path:len())
                local s,_ = vim.regex(ext_pattern):match_str(ref)
                local main_str = ref:sub(1, s)

                return {
                    display = main_str,
                    ordinal = main_str
                }
            end
        },
        sorter = conf.file_sorter(opts),
        attach_mappings = function(prompt_bufnr, map)
            actions.select_default:replace(function()
                actions.close(prompt_bufnr)
                local selection = action_state.get_selected_entry()
                local s,e = vim.regex([[[^/]*$]]):match_str(selection.display)
                local placeholder = selection.display:sub(s+1, e)

                local ref = string.format('[%s]({{< ref "%s" >}})', placeholder, selection.display)
                vim.schedule(function()
                    vim.api.nvim_paste(ref, true, -1)
                    vim.api.nvim_feedkeys(  -- keep insert mode
                        vim.api.nvim_replace_termcodes(
                            string.format('%dhv%dl<C-g>', nc(ref)-2, nc(placeholder)-1),
                            true, false, true
                        ),
                        'n', false)
                end)
            end)
            return true
        end,
    }):find()
end

vim.keymap.set('i', '<C-v><C-p>', function() hw_pages() end, {buffer = true})
END
