local Runner = require("rspec-runner.runner")
local Executor = require("rspec-runner.executor")
local Browser = require("rspec-runner.browser")

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

  vim.api.nvim_create_user_command("RspecRunnerAll", function() M.run("all") end, {})
  vim.api.nvim_create_user_command("RspecRunnerFile", function() M.run("file") end, {})
  vim.api.nvim_create_user_command("RspecRunnerResults", function() M.browse(M.state, M.config) end, {})
end

---@param scope Runner.Scope
function M.run(scope)
  local runner = Runner.new(scope, M.config, {})

  M.state.runner = runner
  return Executor.execute(runner, M.config, M.state)
end

---@param state State
---@param config Config
function M.browse(state, config)
  assert(state.output, "No runner output available.")
  Browser.browse(state.output.examples, config)
end

return M
