---@class Env
---@field cwd string
---@field filename string
---@field filetype string
---@field line number

local M = {}

---@return Env
function M.build()
  return {
    cwd = vim.fn.getcwd(),
    filename = vim.fn.expand("%"),
    filetype = vim.bo.filetype,
    line = vim.fn.line("."),
  }
end

return M
