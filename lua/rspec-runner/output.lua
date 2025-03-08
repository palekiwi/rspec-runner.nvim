---@class Output
---@field examples Output.Example[]

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

local M = {}

---@param str string
local function match_json(str)
  return str:match('{".*}')
end

---@param data string
---@return Output | nil
function M.parse_json(data)
  local json_str = match_json(data)

  if not json_str then return end

  --TODO: add validation with `vim.validate`

  return vim.json.decode(json_str)
end

---@param data string
---@return Output | nil
function M.parse_failures(data)
  local file, line, reason = string.match(data, "([^:]+):([^:]+):(.*)")
  if not file or not line then
    return
  end

  return {
    id = nil,
    description = reason,
    full_description = reason,
    status = "failed",
    file_path = file,
    line_number = line,
    run_time = 0,
    pending_message = vim.NIL
  }
end

return M
