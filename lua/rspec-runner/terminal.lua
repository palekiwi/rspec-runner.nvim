local M = {}

---@param cmd string
function M.small_terminal(cmd)
  vim.cmd.new()
  vim.opt.number = false
  vim.opt.relativenumber = false
  vim.cmd(":startinsert")
  vim.cmd.terminal(cmd)
end

---@param runner Runner
function M.execute(runner)
  local escaped_cmd = vim.tbl_map(
    function(item)
      -- escape all '[' and ']' which occur in spec identifiers
      return item:gsub("([%[%]])", "\\%1")
    end,
    runner.cmd
  )

  M.small_terminal(vim.fn.join(escaped_cmd, " "))
end

return M
