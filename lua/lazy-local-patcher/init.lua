local config = require("lazy-local-patcher.config")

local M = {}

M.setup = config.setup

function M.restore_all()
    require("lazy-local-patcher.patcher").restore_all()
end

function M.apply_all()
    require("lazy-local-patcher.patcher").apply_all()
end

return M
