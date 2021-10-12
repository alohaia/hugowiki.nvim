local M = {}
local configs = vim.g.hexowiki_rmd_auto_trans

if not configs.enable then
    return M
end

M.rmd_writepost = function()
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
    r_handle = vim.loop.spawn('Rscript', {
            args = {configs.r_script},
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
        end)
    )

    vim.loop.read_start(stdout, onread)
    vim.loop.read_start(stderr, onread)
end

return M
