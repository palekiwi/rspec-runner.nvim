local Runner = require("rspec-runner.runner")
local executor = require("rspec-runner.executor")

local M = {
  config = vim.deepcopy(require "rspec-runner.config"),
  state = require("rspec-runner.state").new()
}

---@class UserConfig
---@field cmd string[]

---@param cfg table
function M.setup(cfg)
  if cfg ~= nil then
    M.config = vim.tbl_deep_extend("force", M.config, cfg)
  end

  vim.api.nvim_command "command! RspecRunnerFile lua require('rspec-runner').run('file')<CR>"
  vim.api.nvim_command "command! RspecRunnerAll lua require('rspec-runner').run('all')<CR>"
end

---@param scope Runner.Scope
function M.run(scope)
  local runner = Runner.new(scope, M.config, {})

  M.state.runner = runner
  return executor.execute(runner, M.config, M.state)
end


return M
