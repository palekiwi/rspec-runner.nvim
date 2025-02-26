local runner = require("rspec-runner.runner")

local M = {}

--- Run tests
---
---@param scope string: (all|pr|file|nearest|last)
function M.run(scope)
  local opts = {}

  if scope == "nearest" then
    opts.example = runner.find_nearest()
  end

  return opts
end

return M
