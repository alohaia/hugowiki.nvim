local M = {}
M.hugowiki_rmd_knitting = false
local configs = vim.g.hugowiki_rmd_auto_knit

M.rmd_writepost = function()
    if M.hugowiki_rmd_knitting then
        vim.notify("A knitting job is running.")
        return
    end
    M.hugowiki_rmd_knitting = true

    local stdout = vim.loop.new_pipe(false)
    local stderr = vim.loop.new_pipe(false)
    local results = {}

    local r_handle
    local filename = vim.fn.expand("%:p")
    filename = string.gsub(filename, vim.fn.expand(vim.g.hugowiki_home) .. "/", "")
    r_handle = vim.loop.spawn("Rscript", {
            args = {configs.r_script, filename, string.gsub(filename, "%.Rmd$", ".md")},
            stdio = {nil, stdout, stderr},
            cwd = configs.cwd
        },
        vim.schedule_wrap(function(code, signal)
            stdout:close()
            r_handle:close()
            vim.fn.setqflist({}, 'r', {
                title = '[hugowiki.nvim]RMarkdown knitting output',
                lines = results
            })
            if code ~= 0 or signal ~= 0 then
                vim.notify("Knitting failed, exit with code " .. code .. " and signal " .. signal, vim.log.levels.TRACE)
            else
                vim.notify("Knitting completed.", vim.log.levels.INFO)
            end
            M.hugowiki_rmd_knitting = false
        end)
    )
    local read_start = vim.schedule_wrap(function(err, data)
        if err then
            results = vim.fn.add(results, string.gsub(err, "%s+$", "") .. "\n")
            vim.notify(err, vim.log.levels.ERROR)
        end
        if data then
            results = vim.fn.add(results, string.gsub(data, "%s+$", "") .. "\n")
        end
    end)
    vim.loop.read_start(stdout, read_start)
    vim.loop.read_start(stderr, read_start)
end

M.get_ref = function(reg)
    -- get path
    local root_path = vim.fn.expand(vim.g.hugowiki_home)
    local path = vim.fn.expand("%:p")
    local s1,_ = vim.regex[[\(/_\?index\)\?\.md$]]:match_str(path)
    if s1 then
        path = string.sub(path, string.len(root_path.."/content")+1, s1)
    else
        vim.notify("current file is not under the path specified by hugowiki_home: "..vim.g.hugowiki_home, vim.log.levels.ERROR)
        return false
    end

    -- get anchor
    local line = vim.fn.getline(".")
    local anchor = ""
    local s2,e2 = vim.regex[[^#\+\s.\{-}{\(.*#\zs\S*\ze\|\(.*\s\)id="\zs.\{-}\ze"\?\)}\|^#\+\s\zs.*\ze]]:match_str(line)
    if s2 and e2 then
        anchor = string.sub(line, s2+1, e2)
    end

    local ref = path
    if anchor ~= "" then
        ref = ref .. "#" .. anchor
    end

    if reg then
        vim.fn.setreg(reg, ref)
    end

    if vim.g.hugowiki_snippy_integration == 1 then
        require('snippy.shared').selected_text = ref
    end

    print("ref:", ref)

    return ref
end

return M
