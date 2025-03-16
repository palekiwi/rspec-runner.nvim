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

return Config
