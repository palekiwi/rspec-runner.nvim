local M = {}

---@param path string
---@param line number
function M.view_file(path, line)
  vim.api.nvim_command(string.format("view +%s %s", line, path))
end

return M
