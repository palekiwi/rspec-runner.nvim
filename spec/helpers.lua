local M = {}

---@param path string
---@param line? number
function M.view_file(path, line)
  local cmd
  if line ~= nil then
    cmd = string.format("view +%s %s", line, path)
  else
    cmd = string.format("view %s", path)
  end

  vim.api.nvim_command(cmd)
end

return M
