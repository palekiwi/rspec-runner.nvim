---@alias Config.Command string[] | fun(rspec_args: string[], files: string[]): string[]

---@class Config
---@field namespace number
---@field cmd Config.Command
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
---@field diagnostics? boolean
---@field notify? boolean

---@type Config
local Config = {
  namespace = vim.api.nvim_create_namespace("rspec-runner"),
  cmd = { "rspec" },
  diagnostics = true,
  notify = true,
}

return Config
