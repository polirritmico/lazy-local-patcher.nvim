---@class LazyLocalPatcher.Main
local M = {}

local patcher = "[lazy-local-patcher] "

---@param path string
---@param cmd string[] git command to execute
---@param error_level number? log level for errors. Hide if nil or false
M.git_execute = function(path, cmd, error_level)
  local command = { "git", "-C", path, unpack(cmd) }
  local command_output = vim.fn.system(command)
  if vim.v.shell_error ~= 0 then
    if error_level then
      local msg = patcher .. "Error running git command: %s\n%s"
      error(string.format(msg, patcher, command, command_output), error_level)
    end
    return { success = false, output = command_output }
  end
  return { success = true, output = command_output }
end

---@param name string Name of the plugin repository
---@param plugin_path string Full path of the plugin repository
function M.restore_repo(name, plugin_path)
  local out = M.git_execute(plugin_path, { "restore", "." })
  if not out.success then
    local msg = string.format(": Error restoring the repository. Check '%s'", plugin_path)
    vim.notify(patcher .. name .. msg, vim.log.levels.ERROR)
  end
  vim.notify(patcher .. "Restored " .. name, vim.log.levels.TRACE)
end

---@param name string Name of the plugin repository
---@param patch_path string Full path of the patch file
---@param plugin_path string Full path of the plugin repository
function M.apply_patch(name, patch_path, plugin_path)
  local out = M.git_execute(plugin_path, { "apply", "--ignore-space-change", patch_path })
  if not out.success then
    local msg = string.format(": Error applying patches to the repository. Check '%s'", plugin_path)
    vim.notify(patcher .. name .. msg, vim.log.levels.ERROR)
  end
  vim.notify(patcher .. "Applied " .. name, vim.log.levels.TRACE)
end

---@param opts LazyLocalPatcher.Options
function M.apply_all(opts)
  for patch in vim.fs.dir(opts.patches_path, { depth = 2 }) do
    if patch:match("%.patch$") ~= nil then
      local patch_path = opts.patches_path .. "/" .. patch
      local repo_path = opts.lazy_path .. "/" .. patch:gsub("/.*", ""):gsub("%.patch$", "")
      M.apply_patch(patch, patch_path, repo_path)
    end
  end
end

---@param opts LazyLocalPatcher.Options
function M.restore_all(opts)
  for patch, type in vim.fs.dir(opts.patches_path) do
    if patch:match("%.patch$") ~= nil or type == "directory" then
      local repo_path = opts.lazy_path .. "/" .. patch:gsub("%.patch", "")
      M.restore_repo(patch, repo_path)
    end
  end
end

---@param opts LazyLocalPatcher.Options
function M.create_group_and_cmd(opts)
  local group_id = vim.api.nvim_create_augroup("LazyLocalPatcher", {})
  M.sync_call = false

  vim.api.nvim_create_autocmd("User", {
    desc = "Restore patches when Lazy 'Pre' events are triggered.",
    group = group_id,
    pattern = { "LazySyncPre", "LazyInstallPre", "LazyUpdatePre", "LazyCheckPre" },
    callback = function(ev)
      if not M.sync_call then
        M.restore_all(opts)
      end
      if ev.match == "LazySyncPre" then
        M.sync_call = true
      end
    end,
  })

  vim.api.nvim_create_autocmd("User", {
    desc = "Apply patches when Lazy events are triggered.",
    group = group_id,
    pattern = { "LazySync", "LazyInstall", "LazyUpdate", "LazyCheck" },
    callback = function(ev)
      if not M.sync_call then
        M.apply_all(opts)
      elseif ev.match == "LazySync" then
        M.apply_all(opts)
        M.sync_call = false
      end
    end,
  })
end

return M
