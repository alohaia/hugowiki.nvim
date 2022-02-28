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
        -- assert(not err, err)
        if err then
            results = vim.fn.add(results, string.gsub(err, "%s+$", "") .. "\n")
            vim.notify(err, vim.log.levels.ERROR)
        end
        if data then
            results = vim.fn.add(results, string.gsub(data, "%s+$", "") .. "\n")
            -- vim.notify(data, vim.log.levels.INFO)
        end
    end)
    vim.loop.read_start(stdout, read_start)
    vim.loop.read_start(stderr, read_start)
end

return M
