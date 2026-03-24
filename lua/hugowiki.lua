local M = {}
-- M.hugowiki_rmd_knitting = false
local configs = vim.g.hugowiki_rmd_auto_knit

local uv = vim.loop

local function spawn(cmd, args, cb, cwd)
    -- IO
    local stdout = uv.new_pipe(false)
    local stderr = uv.new_pipe(false)
    local output = {}

    local handle
    handle = uv.spawn(
        cmd,
        { args = args, stdio = {nil, stdout, stderr}, cwd = cwd },
        function(code, signal)
            stdout:close()
            handle:close()

            if cb ~= nil then
                -- wrap callback function
                cb = vim.schedule_wrap(cb)
                cb(output, code, signal)
            end
        end
    )

    -- stderr
    uv.read_start(stderr, function(err, data)
        -- handle read error
        if err then
            vim.notify("stderr read error: " .. err, vim.log.levels.ERROR)
        end

        vim.notify(data, vim.log.levels.ERROR)
    end)

    -- stdout
    uv.read_start(stdout, function(err, data)
        -- handle read error
        if err then
            vim.notify("stdout read error: " .. err, vim.log.levels.ERROR)
        end

        if data then
            table.insert(output, data)
        end
    end)
end

M.rmd_writepost = function()
    vim.notify("Start knitting", vim.fn.expand("%:p"))
    if M.hugowiki_rmd_knitting then
        vim.notify("A knitting job is still running.")
        return
    end
    M.hugowiki_rmd_knitting = true

    local filename = vim.fn.expand("%:p")
    filename = string.gsub(filename, vim.fn.expand(vim.g.hugowiki_home) .. "/", "")
    spawn("Rscript", {
            vim.fn.expand(configs.r_script), filename, string.gsub(filename, "%.Rmd$", ".md")
        },
        function(output, code, signal)
            vim.fn.setqflist({}, 'r', {
                title = '[hugowiki.nvim] RMarkdown knitting output',
                lines = output
            })
            if code ~= 0 or signal ~= 0 then
                vim.notify("Knitting failed, exit with code " .. code .. " and signal " .. signal, vim.log.levels.TRACE)
                -- vim.notify(vim.fn.join(output, "\n"), vim.log.levels.ERROR)
            else
                vim.notify("Knitting completed.", vim.log.levels.INFO)
            end
            M.hugowiki_rmd_knitting = false
        end,
        vim.fn.expand(configs.cwd)
    )
end

M.get_ref = function(reg)
    -- get path
    local root_path = vim.fn.expand(vim.g.hugowiki_home)
    local path = vim.fn.expand("%:p")
    local s1,_ = vim.regex[[\(/_\?index\)\?\.R\?md$]]:match_str(path)
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

    -- if vim.g.hugowiki_snippy_integration == 1 then
    --     require('snippy.shared').selected_text = ref
    -- end

    print("ref:", ref)

    return ref
end

return M
