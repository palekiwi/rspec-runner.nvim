local runner = require("rspec-runner.runner")
local utils = require("rspec-runner.utils")
local State = require("rspec-runner.state")

---@class ExecOpts
---@field cmd string[]
---@field examples string[]
---@field filename? string
---@field scope string
---@field files string[]

local M = {}
vim.g.state = State.new()

local ns = vim.api.nvim_create_namespace("rspec-runner")

---
---@param scope string: (all|pr|file|nearest|last)
function M.run(scope)
  -- TODO: check filetype vim.bo.filetype
  ---@type ExecOpts
  local opts = {
    cmd = { "rspec", "--format", "j" },
    examples = {},
    scope = scope,
    files = {}
  }

  if scope == "nearest" then
    opts.examples = runner.find_nearest()
  end

  M.exec(opts)
end

---@param opts ExecOpts
function M.exec(opts)
  local state = State.new()

  local function on_exit()
    if #state.examples == 0 then
      vim.notify("error")
      return
    end

    local failed = {}
    local count = 0

    vim.api.nvim_buf_clear_namespace(0, ns, 0, -1)

    for _, example in ipairs(state.examples) do
      local bufnr = vim.fn.bufnr(example.filename, true)
      vim.diagnostic.reset(ns)

      vim.notify(vim.inspect(example))
      if not example.success then
        failed[bufnr] = failed[bufnr] or {}

        table.insert(failed[bufnr], {
          bufnr = bufnr,
          lnum = example.line,
          col = 1,
          severity = vim.diagnostic.severity.ERROR,
          source = "rspec-live-tests",
          message = example.exception.message,
          user_data = {},
        })

        count = count + 1
      end
    end

    for bufnr, entries in pairs(failed) do
      vim.diagnostic.set(ns, bufnr, entries, {})
    end

    vim.diagnostic.setqflist({open = true, namespace = ns, title = "RSpec Failures" })

    vim.g.state = state
    vim.notify(vim.inspect(vim.g.state))
  end

  local function on_stdout(err, data)
    if err then
      print("An error has occurred: %s", err)
      return
    end

    if data then
      local decoded = vim.json.decode(utils.match_json(data))

      local results = vim.tbl_map(function(ex)
        local result = {
          success = true,
          description = ex.description,
          filename = ex.file_path,
          line = ex.line_number
        }

        if ex.status == "failed" then
          result = vim.tbl_deep_extend("force", result, {
            success = false,
            exception = ex.exception
          })
        end

        return result
      end, decoded.examples)

      state.examples = results
    end
  end

  local cmd = opts.cmd
  local settings = { stdout = on_stdout }

  vim.system(cmd, settings, function() vim.schedule(on_exit) end)
end

M.run("all")


return M
