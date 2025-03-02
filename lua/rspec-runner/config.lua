---@class Config
---@field cmd string[]
---@field diagnostics boolean
---@field qflist boolean
---@field namespace number
---@field notify boolean

---@type Config
local Config = {
  cmd = { "rspec" },
  diagnostics = true,
  qflist = true,
  namespace = vim.api.nvim_create_namespace("rspec-runner"),
  notify = true,
}

return Config
