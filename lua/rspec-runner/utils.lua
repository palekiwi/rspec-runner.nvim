local M = {}

---@param str string
function M.match_json(str)
  return str:match('{".*}')
end

return M
