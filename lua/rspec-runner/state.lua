---@class State
---@field output Output
---@field runner? Runner
---@field job? vim.SystemObj
---@field errors string[]

local M = {}

---@return State
function M.new()
  return {
    errors = {},
    output = {
      examples = {},
      passed_count = 0,
      failed_count = 0,
    }
  }
end

return M
