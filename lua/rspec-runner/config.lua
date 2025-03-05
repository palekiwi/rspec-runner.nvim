---@class Config
---@field namespace number
---@field cmd string[]
---@field diagnostics boolean
---@field notify boolean
---@field spec_patterns string[]

---@class UserConfig
---@field defaults? UserConfig.Defaults
---@field projects? UserConfig.Project[]

---@class UserConfig.Project
---@field path string
---@field cmd? string[]
---@field diagnostics? boolean
---@field notify? boolean
---@field spec_patterns? string[]

---@class UserConfig.Defaults
---@field cmd? string[]
---@field diagnostics? boolean
---@field notify? boolean
---@field spec_patterns? string[]

---@type Config
local Config = {
  namespace = vim.api.nvim_create_namespace("rspec-runner"),
  cmd = { "rspec" },
  diagnostics = true,
  notify = true,
  spec_patterns = { "_spec%.rb$" }
}

return Config
