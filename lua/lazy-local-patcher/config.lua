---@class PatcherConfig
local M = {}

---@type PatcherOptions
M.options = {}

---@class PatcherOptions
local defaults = {
  lazy_path = vim.fn.stdpath("data") .. "/lazy", -- directory where lazy install the plugins
  patches_path = vim.fn.stdpath("config") .. "/patches", -- directory where diff patches files are stored
}

---@param path string
local check_paths = function(path)
  local output = vim.fn.finddir(path)
  if output == "" then
    vim.notify("[lazy-local-patcher] Error: Not found directory " .. path)
  end
end

---@param options PatcherOptions?
function M.setup(options)
  M.options = vim.tbl_deep_extend("force", {}, defaults, options or {})
  check_paths(M.options.lazy_path)
  check_paths(M.options.patches_path)
  require("lazy-local-patcher.patcher").create_group_and_cmd()
end

return M
