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
  local cmd = vim.deepcopy(runner.cmd)

  M.small_terminal(vim.fn.join(cmd, " "))
end

return M
