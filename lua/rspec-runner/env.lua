---@class Env
---@field cwd string
---@field filename string
---@field filetype string
---@field line number

local M = {}

---Normalize a buffer path to be relative to the current working directory.
---
---Neovim may load a buffer with an absolute path, which RSpec cannot load
---(`require` rejects absolute paths). `:.` makes the path relative to cwd when
---possible and leaves already-relative paths untouched.
---
---@param filename string
---@return string
local function relative(filename)
  return vim.fn.fnamemodify(filename, ":.")
end

---@return Env
function M.build()
  return {
    cwd = vim.fn.getcwd(),
    filename = relative(vim.fn.expand("%")),
    filetype = vim.bo.filetype,
    line = vim.fn.line("."),
  }
end

return M
