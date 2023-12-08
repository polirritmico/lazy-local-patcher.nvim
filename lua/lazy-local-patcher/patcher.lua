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

function M.create_group_and_cmd()
    local group_id = vim.api.nvim_create_augroup("LazyPatches", {})
    local patches_path = Config.options.patches_path
    local lazy_path = Config.options.lazy_path

    vim.api.nvim_create_autocmd("User", {
        desc = "Apply/clean patches when Lazy events are triggered.",
        pattern = {
            "LazySync*", -- before/after running sync.
            "LazyInstall*", -- before/after an install
            "LazyUpdate*", -- before/after an update
            "LazyCheck*", -- before/after checking for updates
        },
        group = group_id,
        callback = function(info)
            for patch in vim.fs.dir(patches_path) do
                local patch_path = patches_path .. "/" .. patch
                local repo_path = lazy_path .. "/" .. patch:gsub("%.patch", "")
                -- if vim.uv.fs_stat(repo_path) then
                if vim.loop.fs_stat(repo_path) then
                    M.restore_repo(patch, repo_path)
                    if not info.match:match("Pre$") then
                        M.apply_patch(patch, patch_path, repo_path)
                    end
                end
            end
        end,
    })
end

function M.restore_all()
    for patch in vim.fs.dir(Config.options.patches_path) do
        local repo_path = Config.options.lazy_path .. "/" .. patch:gsub("%.patch", "")
        M.restore_repo(patch, repo_path)
    end
end

function M.apply_all()
    for patch in vim.fs.dir(Config.options.patches_path) do
        local patch_path = Config.options.patches_path .. "/" .. patch
        local repo_path = Config.options.lazy_path .. "/" .. patch:gsub("%.patch", "")
        M.apply_patch(patch, patch_path, repo_path)
    end
end

return M
