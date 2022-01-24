local M = {}
M.hugowiki_rmd_knitting = false
local configs = vim.g.hugowiki_rmd_auto_knit

M.rmd_writepost = function()
    if M.hugowiki_rmd_knitting then
        print("A knitting job is running.")
        return
    end
    M.hugowiki_rmd_knitting = true

    local stdin = vim.loop.new_pipe(false)
    local stdout = vim.loop.new_pipe(false)
    local stderr = vim.loop.new_pipe(false)

    local onread = vim.schedule_wrap(function(err, data)
        if err then
            print('ERROR: ', err)
            -- TODO handle err
        end
        if data then
            print(data)
        end
    end)

    local r_handle
    local filename = vim.fn.expand("%:p")
    r_handle = vim.loop.spawn('Rscript', {
            args = {configs.r_script, filename, string.gsub(filename, "%.Rmd$", ".md")},
            stdio = {stdin, stdout, stderr},
            cwd = configs.cwd
        },
        vim.schedule_wrap(function(code, signal)
            stdin:close()
            stdout:close()
            stderr:close()
            r_handle:close()
            if code ~= 0 or signal ~= 0 then
                print('exit with', code, signal)
            end
            M.hugowiki_rmd_knitting = false
        end)
    )

    vim.loop.read_start(stdout, onread)
    vim.loop.read_start(stderr, onread)
end

return M
