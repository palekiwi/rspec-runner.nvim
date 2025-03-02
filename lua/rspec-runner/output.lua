---@class Output
---@field version string
---@field examples Output.Example[]
---@field summary Output.Summary
---@field summary_line string

---@class Output.Example
---@field id string
---@field full_description string
---@field status "passed" | "failed" | "pending"
---@field file_path string
---@field line_number number
---@field run_time number
---@field pending_message string | vim.NIL
---@field exception Output.Example.Exception | vim.NIL

---@class Output.Example.Exception
---@field class string
---@field message string
---@field backtrace string[]

---@class Output.Summary
---@field duration number
---@field example_count number
---@field failure_count number
---@field pending_count number
---@field errors_outside_of_examples_count number

local M = {}

---@param str string
local function match_json(str)
  return str:match('{".*}')
end

---@param data string
---@return Output | nil
function M.parse(data)
  local json_str = match_json(data)

  if not json_str then return end

  --TODO: add validation with `vim.validate`

  return vim.json.decode(json_str)
end

return M
