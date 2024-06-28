local util = require("lazy-local-patcher.util")
local Config = require("lazy-local-patcher.config")

local M = {}

---@param name string Name of the plugin repository
---@param plugin_path string Full path of the plugin repository
function M.restore_repo(name, plugin_path)
  vim.notify("[patches: " .. name .. "] Restoring plugin repository...", 0)
  util.git_execute(plugin_path, { "restore", "." })
  vim.notify("[patches: " .. name .. "] Done", 0)
end

---@param name string Name of the plugin repository
---@param patch_path string Full path of the patch file
---@param plugin_path string Full path of the plugin repository
function M.apply_patch(name, patch_path, plugin_path)
  vim.notify("[patches: " .. name .. "] Applying patch...", 0)
  util.git_execute(plugin_path, { "apply", "--ignore-space-change", patch_path })
  vim.notify("[patches: " .. name .. "] Done", 0)
end

function M.apply_all()
  for patch in vim.fs.dir(Config.options.patches_path) do
    local patch_path = Config.options.patches_path .. "/" .. patch
    local repo_path = Config.options.lazy_path .. "/" .. patch:gsub("%.patch", "")
    M.apply_patch(patch, patch_path, repo_path)
  end
end

function M.restore_all()
  for patch in vim.fs.dir(Config.options.patches_path) do
    local repo_path = Config.options.lazy_path .. "/" .. patch:gsub("%.patch", "")
    M.restore_repo(patch, repo_path)
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
