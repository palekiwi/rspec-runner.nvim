local rspec_query = require "rspec-runner.query"

local ts = vim.treesitter
local parsers = require "nvim-treesitter.parsers"

---@alias Runner.Scope "all"

---@class Runner.Opts
---@field cwd? string
---@field filename? string
---@field line? number

---@class Runner
---@field cwd string
---@field examples string[]
---@field filename string
---@field line number
---@field files string[]
---@field scope Runner.Scope
local Runner = {}

Runner.__index = Runner

---@param scope Runner.Scope
---@param opts? Runner.Opts
---@return Runner
function Runner:new(scope, opts)
  opts = opts or {}

  self.cwd = opts.cwd or vim.fn.getcwd()
  self.filename = opts.filename or vim.fn.expand("%")
  self.line = opts.line or vim.fn.line(".")
  self.scope = scope
  self.examples = {}
  self.files = {}

  return self
end
---@return Runner
function Runner:setup()
  return self
end

---@return string[]
function Runner:find_nearest()
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

---@return string[]
function Runner:build_args()
  return { "--format", "j" }
end

return Runner
