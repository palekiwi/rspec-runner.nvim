local Runner = require("rspec-runner.runner")
local executor = require("rspec-runner.executor")

local M = {
  config = vim.deepcopy(require "rspec-runner.config"),
  state = require("rspec-runner.state").new()
}

vim.g.state = M.state

---
---@param scope string: (all|pr|file|nearest|last)
function M.run(scope)
  local runner = Runner:new(scope)

  M.state.runner = runner
  return executor.execute(runner, M.config, M.state)
end

vim.keymap.set("n", "<leader>rn", function() M.run("all") end)

return M
