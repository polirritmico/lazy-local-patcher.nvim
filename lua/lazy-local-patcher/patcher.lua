local util = require("lazy-local-patcher.util")
local Config = require("lazy-local-patcher.config")

local M = {}

local patcher = "[lazy-local-patcher] "

---@param name string Name of the plugin repository
---@param plugin_path string Full path of the plugin repository
function M.restore_repo(name, plugin_path)
  local out = util.git_execute(plugin_path, { "restore", "." })
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
  local out = util.git_execute(plugin_path, { "apply", "--ignore-space-change", patch_path })
  if not out.success then
    local msg = string.format(": Error applying patches to the repository. Check '%s'", plugin_path)
    vim.notify(patcher .. name .. msg, vim.log.levels.ERROR)
  end
  vim.notify(patcher .. "Applied " .. name, vim.log.levels.TRACE)
end

function M.apply_all()
  for patch in vim.fs.dir(Config.options.patches_path) do
    if patch:match("%.patch$") ~= nil then
      local patch_path = Config.options.patches_path .. "/" .. patch
      local repo_path = Config.options.lazy_path .. "/" .. patch:gsub("%.patch", "")
      M.apply_patch(patch, patch_path, repo_path)
    end
  end
end

function M.restore_all()
  for patch in vim.fs.dir(Config.options.patches_path) do
    if patch:match("%.patch$") ~= nil then
      local repo_path = Config.options.lazy_path .. "/" .. patch:gsub("%.patch", "")
      M.restore_repo(patch, repo_path)
    end
  end
end

function M.create_group_and_cmd()
  local group_id = vim.api.nvim_create_augroup("LazyPatches", {})
  M.sync_call = false

  vim.api.nvim_create_autocmd("User", {
    desc = "Restore patches when Lazy 'Pre' events are triggered.",
    group = group_id,
    pattern = { "LazySyncPre", "LazyInstallPre", "LazyUpdatePre", "LazyCheckPre" },
    callback = function(ev)
      if not M.sync_call then
        M.restore_all()
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
        M.apply_all()
      elseif ev.match == "LazySync" then
        M.apply_all()
        M.sync_call = false
      end
    end,
  })
end

return M
