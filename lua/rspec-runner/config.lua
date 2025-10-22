---@alias Config.Command string[] | fun(rspec_args: string[], files: string[]): string[]
---@alias Config.Flags.Terminal.Format "documentation" | "progress" | "failures"
---@alias Config.Flags { terminal: { format: Config.Flags.Terminal.Format } }
---
---@alias UserConfig.Flags { terminal?: { format: Config.Flags.Terminal.Format } }

---@class Config
---@field namespace number
---@field cmd Config.Command
---@field flags Config.Flags
---@field notify boolean
---@field git_base? fun(): string?

---@class UserConfig
---@field defaults? UserConfig.Defaults
---@field projects? UserConfig.Project[]

---@class UserConfig.Project
---@field path string
---@field cmd? Config.Command
---@field notify? boolean

---@class UserConfig.Defaults
---@field cmd? Config.Command
---@field flags? UserConfig.Flags
---@field diagnostics? boolean
---@field notify? boolean

local function parse_env_cmd()
  local env_cmd = vim.fn.getenv("RSPEC_RUNNER_CMD")
  if env_cmd == vim.NIL or env_cmd == "" then
    return nil
  end
  return vim.split(env_cmd, " ")
end

local function parse_env_notify()
  local env_notify = vim.fn.getenv("RSPEC_RUNNER_NOTIFY")
  if env_notify == vim.NIL or env_notify == "" then
    return nil
  end
  return env_notify == "true" or env_notify == "1"
end

local function parse_env_terminal_format()
  local env_format = vim.fn.getenv("RSPEC_RUNNER_TERMINAL_FORMAT")
  if env_format == vim.NIL or env_format == "" then
    return nil
  end
  if env_format == "documentation" or env_format == "progress" or env_format == "failures" then
    return env_format
  end
  return nil
end

local function get_env_config()
  local env_config = {}
  
  local cmd = parse_env_cmd()
  if cmd then
    env_config.cmd = cmd
  end
  
  local notify = parse_env_notify()
  if notify ~= nil then
    env_config.notify = notify
  end
  
  local format = parse_env_terminal_format()
  if format then
    env_config.flags = {
      terminal = {
        format = format,
      },
    }
  end
  
  return env_config
end

---@type Config
local Config = {
  namespace = vim.api.nvim_create_namespace("rspec-runner"),
  cmd = { "rspec" },
  notify = false,
  flags = {
    terminal = {
      format = "documentation",
    },
  }
}

local env_config = get_env_config()
Config = vim.tbl_deep_extend("force", Config, env_config)

Config.get_env_config = get_env_config

return Config
