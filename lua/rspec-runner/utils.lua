local M = {}

---Concat tables
---
---@param r table a target table
---@param t table a table
---@return table r a target table
function M.concat(r, t)
  for _, value in ipairs(t) do
    table.insert(r, value)
  end
  return r
end

return M
