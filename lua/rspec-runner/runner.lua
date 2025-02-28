local rspec_query = require "rspec-runner.query"

local ts = vim.treesitter
local parsers = require "nvim-treesitter.parsers"

local M = {}

---@return string[]
function M.find_nearest()
  local lang = "ruby"
  local result = {}

  parsers.get_parser(0, lang)
  local query = ts.query.parse(lang, rspec_query)

  local curnode = ts.get_node()

  while curnode do
    for id, capture_node in query:iter_captures(curnode, 0) do

      if query.captures[id] == "test_name" then
        table.insert(result, 1, ts.get_node_text(capture_node, 0))
        return result
      end
    end

    curnode = curnode:parent()
  end

  return result
end

vim.keymap.set({ 'n' }, 'rn', M.find_nearest)

return M
