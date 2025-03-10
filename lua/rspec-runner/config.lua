---@class Config
---@field namespace number
---@field cmd string[]
---@field notify boolean
---@field git_base? fun(): string?

---@class UserConfig
---@field defaults? UserConfig.Defaults
---@field projects? UserConfig.Project[]

---@class UserConfig.Project
---@field path string
---@field cmd? string[]
---@field notify? boolean

---@class UserConfig.Defaults
---@field cmd? string[]
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
