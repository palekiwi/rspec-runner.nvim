local M = {}

---@class Example
---@field id? string
---@field full_description? string
---@field description string
---@field status "passed" | "failed" | "pending"
---@field file_path string
---@field line_number number
---@field run_time? number
---@field pending_message? string
---@field exception? Example.Exception

---@class Example.Exception
---@field class string
---@field message string
---@field backtrace string[]

---@param input string
local function match_json(input)
  return input:match('{".*}')
end

---@param data string
---@return string? error, Example[]
function M.decode(data)
  -- intput may include other text before/after valid json
  local json_str = match_json(data)

  if not json_str then
    return nil, {}
  end

  local ok, result = pcall(vim.json.decode, json_str)

  if not ok then
    return "Invalid json", {}
  else
    return M.decode_examples(result)
  end
end

---@param data table
---@return string? error, Example[]
function M.decode_examples(data)
  local err
  local result = {}

  if type(data.examples) == "table" then
    for _, item in pairs(data.examples) do
      local example
      err, example = M.decode_example(item)

      if err then
        return err, {}
      else
        table.insert(result, example)
      end
    end
  end

  return nil, result
end

---@param data table
---@return string? error, Example
function M.decode_example(data)
  local err
  local ok

  ok, err = pcall(vim.validate, {
    id = { data.id, "string" },
    full_description = { data.full_description, "string" },
    description = { data.description, "string" },
    status = { data.status, "string" },
    file_path = { data.file_path, "string" },
    line_number = { data.line_number, "number" },
    exception = { data.exception, "table", true }
  })

  if not ok then
    return err, {}
  end

  if data.status == "failed" then
    local exception = data.exception
    vim.validate {
      class = { exception.class, "string" },
      message = { exception.message, "string" },
      backtrace = { exception.backtrace, "table" },
    }
  end

  return nil, data
end

return M
