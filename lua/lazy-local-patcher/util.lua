M = {}

---@param path string
---@param cmd string[] git command to execute
---@param error_level number? log level for errors. Hide if nil or false
M.git_execute = function(path, cmd, error_level)
    local command = { "git", "-C", path, unpack(cmd) }
    local command_output = vim.fn.system(command)
    if vim.v.shell_error ~= 0 then
        if error_level then
            M.error(command, command_output, error_level)
        end
        return { success = false, output = command_output }
    end
    return { success = true, output = command_output }
end

return M
