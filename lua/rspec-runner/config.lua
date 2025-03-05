---@class Config
---@field cmd string[]
---@field diagnostics boolean
---@field qflist boolean
---@field namespace number
---@field notify boolean
---@field spec_patterns string[]

---@type Config
local Config = {
  cmd = { "rspec" },
  diagnostics = true,
  namespace = vim.api.nvim_create_namespace("rspec-runner"),
  notify = true,
  spec_patterns = { "_spec%.rb$" }
}

return Config
