local Runner = require("rspec-runner.runner")
local Executor = require("rspec-runner.executor")
local Browser = require("rspec-runner.browser")
local Notifier = require("rspec-runner.notifier")
local Terminal = require("rspec-runner.terminal")

local M = {
  config = vim.deepcopy(require "rspec-runner.config"),
  state = require("rspec-runner.state").new()
}

---@alias Scope "all" | "base" | "file" | "last" | "nearest" |

---@param scope Scope
function M.run(scope)
  local err
  local runner
  local notifier = Notifier.new(M.config)

  if M.state.job and not M.state.job:is_closing() then
    notifier:run_in_progress()
    return M.state.job
  end

  if scope == "last" then
    if M.state.output == nil or M.state.runner == nil then
      notifier:error("No previous runs.")
      return
    end

    runner = Runner.from_last(M.state.runner, M.state.output, M.config)
  else
    err, runner = Runner.new(scope, M.config)
    if err then
      notifier:error(err)
      return
    end
  end

  M.state.runner = runner

  return Executor.execute(runner, M.config, M.state)
end
---
---@param scope Scope
function M.term_run(scope)
  local err
  local runner
  local notifier = Notifier.new(M.config)

  if M.state.job and not M.state.job:is_closing() then
    notifier:run_in_progress()
    return M.state.job
  end

  if scope == "last" then
    notifier:error("Not supported in term.")
    return
  else
    err, runner = Runner.new(scope, M.config, { term = true })
    if err then
      notifier:error(err)
      return
    end
  end

  M.state.runner = runner

  return Terminal.execute(runner)
end

---@param state State
function M.cancel_run(state)
  local job = state.job
  if job == nil then
    return
  else
    job:kill(2)
  end
end

---@param state State
---@param config Config
function M.browse(state, config)
  if M.state.output == nil then
    Notifier.new(config):error("No previous runs.")
  else
    Browser.browse(state.output.examples, config)
  end
end

---@param cfg UserConfig
function M.setup(cfg)
  if cfg ~= nil then
    local default_config = cfg.defaults or {}
    local projects_config = cfg.projects or {}
    local cwd = vim.fn.getcwd()

    local cwd_overrides = vim.iter(projects_config):find(function(project)
      return string.match(cwd, project.path)
    end)

    if cwd_overrides ~= nil then
      local user_config = vim.tbl_deep_extend("force", default_config, cwd_overrides)
      M.config = vim.tbl_deep_extend("force", M.config, user_config)
    else
      M.config = vim.tbl_deep_extend("force", M.config, default_config)
    end

  end

  vim.api.nvim_create_user_command("RspecRunnerAll", function() M.run("all") end, {})
  vim.api.nvim_create_user_command("RspecRunnerBase", function() M.run("base") end, {})
  vim.api.nvim_create_user_command("RspecRunnerFile", function() M.run("file") end, {})
  vim.api.nvim_create_user_command("RspecRunnerLast", function() M.run("last") end, {})
  vim.api.nvim_create_user_command("RspecRunnerNearest", function() M.run("nearest") end, {})
  vim.api.nvim_create_user_command("RspecRunnerCancel", function() M.cancel_run(M.state) end, {})
  vim.api.nvim_create_user_command("RspecRunnerShowResults", function() M.browse(M.state, M.config) end, {})
  vim.api.nvim_create_user_command("RspecRunnerTermAll", function() M.term_run("all") end, {})
  vim.api.nvim_create_user_command("RspecRunnerTermBase", function() M.term_run("base") end, {})
  vim.api.nvim_create_user_command("RspecRunnerTermFile", function() M.term_run("file") end, {})
  vim.api.nvim_create_user_command("RspecRunnerTermNearest", function() M.term_run("nearest") end, {})
end

return M
