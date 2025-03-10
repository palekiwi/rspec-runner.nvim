local rspec_query = require "rspec-runner.query"
local utils = require "rspec-runner.utils"
local Env = require "rspec-runner.env"

local ts = vim.treesitter
local parsers = require "nvim-treesitter.parsers"

---@class Runner
---@field cmd string[]
---@field env Env
---@field scope Scope
---@field files string[]

local M = {}

---@param scope Scope
---@param config Config
---@return string? error, Runner
function M.new(scope, config)
  local files = {}
  local runner = {}
  local env = Env.build()

  if scope == "file" then
    local spec = M.spec_for(env.filename)

    if not spec then
      return "No spec file for current file.", runner
    end

    files = { spec }
  elseif scope == "nearest" then
    if not M.is_specfile(env.filename) then
      return "Not a specfile.", {}
    end

    local line = M.find_nearest()
    if not line then
      return "No matching test block found.", {}
    end

    files = { string.format("%s:%s", env.filename, line)}
  elseif scope == "base" then
    local base = "master"

    if config.git_base then
      base = config.git_base() or base
    end

    files = M.specs_for_base(base)
    if (#files) == 0 then
      return "No specs found in scope BASE for: " .. base, runner
    end
  end

  local cmd = M.build_cmd(scope, files, config)

  runner = {
    cmd = cmd,
    env = env,
    scope = scope,
    files = files
  }

  return nil, runner
end

---@param last_runner Runner
---@param output Output
---@param config Config
---@return Runner
function M.from_last(last_runner, output, config)
  local files = {}
  local env = last_runner.env
  local scope = last_runner.scope

  -- if last scope was "nearest", grab the ids of examples that were run
  if last_runner.scope == "nearest" then
    files = vim.tbl_map(
      function(example) return example.id end,
      output.examples
    )
  else
    files = last_runner.files
  end

  return {
    env = env,
    scope = scope,
    files = files,
    cmd = M.build_cmd(scope, files, config)
  }
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

---@param scope Scope
---@param files string[]
---@param config Config
---@return string[]
function M.build_cmd(scope, files, config)
  if scope == "all" then
    return utils.concat(config.cmd, { "--format", "j"})
  else
    local args = utils.concat({ "--format", "j" }, files)
    return utils.concat(config.cmd, args)
  end
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

---@param base string branch name or commit hash
---@return string[]
function M.changed_files(base)
  local command = "git diff --name-only $(git merge-base HEAD " .. base .. " )"

  local handle = assert(io.popen(command))
  local result = handle:read("*a")
  handle:close()

  local files = {}

  for token in string.gmatch(result, "[^%s]+") do
    table.insert(files, token)
  end

  return files
end

---@param base string branch name or commit hash
function M.specs_for_base(base)
  local set = {}

  for _, el in ipairs(M.changed_files(base)) do
    local spec = M.spec_for(el)

    if spec then
      set[spec] = true
    end
  end

  return vim.tbl_keys(set)
end

return M
