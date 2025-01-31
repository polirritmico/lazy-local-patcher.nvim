local patcher = require("lazy-local-patcher.patcher")

---@class LazyLocalPatcher
local M = {}

---@class LazyLocalPatcher.Options
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

---@param options LazyLocalPatcher.Options?
function M.setup(options)
  M.options = vim.tbl_deep_extend("force", {}, defaults, options or {})

  check_paths(M.options.lazy_path)
  check_paths(M.options.patches_path)
  patcher.create_group_and_cmd(M.options)
end

function M.restore_all()
  patcher.restore_all(M.options)
end

function M.apply_all()
  patcher.apply_all(M.options)
end

return M
