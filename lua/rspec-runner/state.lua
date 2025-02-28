---@class State
---@field examples State.Example[]

---@class State.Example.Exception
---@field message string

---@class State.Example
---@field success boolean
---@field description string
---@field filename string
---@field line number
---@field exception State.Example.Exception

local M = {}

---@return State
function M.new()
  return {
    examples = {}
  }
end

return M
