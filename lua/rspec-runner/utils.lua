local M = {}

---Concat tables
---
---@param a table a target table
---@param b table a table
---@return table
function M.concat(a, b)
  local res = {}

  for _, v in ipairs(a) do
    table.insert(res, v)
  end

  for _, v in ipairs(b) do
    table.insert(res, v)
  end

  return res
end

return M
