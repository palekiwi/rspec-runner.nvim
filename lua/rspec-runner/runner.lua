local rspec_query = require "rspec-runner.query"

local ts = vim.treesitter
local parsers = require "nvim-treesitter.parsers"

---@alias Runner.Scope "all" | "file" | "last" | "nearest"

---@class Runner.Opts
---@field cwd? string
---@field filename? string
---@field line? number

---@class Runner.Config
---@field cwd string
---@field examples string[]
---@field filename string
---@field line number
---@field files string[]
---@field scope Runner.Scope

---@class Runner
---@field cmd string[]
---@field cfg Runner.Config

local M = {}

---@param scope Runner.Scope
---@param config Config
---@param opts? Runner.Opts
---@return Runner
function M.new(scope, config, opts)
  opts = opts or {}

  local cfg = {
    cwd = opts.cwd or vim.fn.getcwd(),
    filename = opts.filename or vim.fn.expand("%"),
    line = opts.line or vim.fn.line("."),
    examples = {},
    scope = scope,
    files = {},
  }

  if scope == "file" then
    local spec = M.spec_for(cfg.filename)

    if spec == nil then
      error("No spec file for the current file: " .. cfg.filename)
    else
      cfg.files = { spec }
    end
  elseif scope == "nearest" then
    assert(M.is_specfile(cfg.filename), "Not a specfile.")
    local line = M.find_nearest()
    assert(line, "No test block found.")
    cfg.files = { string.format("%s:%s", cfg.filename, line)}
  end

  local cmd = M.build_cmd(cfg, config)

  return { cmd = cmd, cfg = cfg }
end

---@param last_runner Runner
---@param output Output
---@return Runner
function M.from_last(last_runner, output, config)
  local files = {}

  if last_runner.cfg.scope == "nearest" then
    files = vim.tbl_map(function(example)
      return example.id
    end, output.examples)
  else
    files = last_runner.cfg.files
  end

  local cfg = {
    cwd = last_runner.cfg.cwd,
    filename = last_runner.cfg.cwd,
    line = last_runner.cfg.line,
    examples = {},
    scope = "last",
    files = files
  }

  local cmd = M.build_cmd(cfg, config)

  return { cmd = cmd, cfg = cfg }
end

---@return number?
function M.find_nearest()
  local lang = "ruby"
  local line = nil

  parsers.get_parser(0, lang)
  local query = ts.query.parse(lang, rspec_query)

  local curnode = ts.get_node()

  while curnode do
    for id, capture_node in query:iter_captures(curnode, 0) do
      if query.captures[id] == "test_name" then
        line = capture_node:range() + 1
        return line
      end
    end

    curnode = curnode:parent()
  end

  return line
end

---@param runner_cfg Runner.Config
---@param config Config
---@return string[]
function M.build_cmd(runner_cfg, config)
  local cmd = vim.deepcopy(config.cmd)
  local args = vim.deepcopy({ "--format", "j" })

  if runner_cfg.scope == "all" then
    vim.list_extend(cmd, args)
  else
    vim.list_extend(args, runner_cfg.files)
    vim.list_extend(cmd, args)
  end

  return cmd
end

---@param filepath string
---@return boolean
function M.is_specfile(filepath)
  return string.match(filepath, "_spec%.rb$") ~= nil
end

---@param filepath string
---@return string?
function M.spec_for(filepath)
  if M.is_specfile(filepath) then
    return filepath
  else
    local root, dirname, filename = string.match(filepath, "([^%/]+)/(.*)/([^%/]+).rb$")

    local variants = {
      string.format("spec/%s/%s_spec.rb", dirname, filename),
      string.format("%s/%s/%s_spec.rb", root, dirname, filename),
    }

    for _, variant in pairs(variants) do
      if vim.fn.filereadable(variant) == 1 then
        return variant
      end
    end

    return nil
  end
end

return M
