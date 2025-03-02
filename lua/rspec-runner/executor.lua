local output = require("rspec-runner.output")
local utils = require("rspec-runner.utils")

local M = {}

---@param runner Runner
---@param config Config
---@param state State
function M.execute(runner, config, state)
  local ns = config.namespace

  local function on_stdout(err, data)
    if err then
      print("An error has occurred: %s", err)
      return
    end

    if data then
      local valid_output = output.parse(data)

      if valid_output then
        state.output = valid_output
      end
    end
  end

  local function on_exit()
    if #state.output.examples == 0 then
      print("Error: no examples")
      return
    end

    local failed = {}

    vim.api.nvim_buf_clear_namespace(0, ns, 0, -1)

    for _, example in ipairs(state.output.examples) do
      local bufnr = vim.fn.bufnr(example.file_path, true)

      if config.diagnostics then
        vim.diagnostic.reset(ns)
      end

      if example.status == "failed" then
        failed[bufnr] = failed[bufnr] or {}

        table.insert(failed[bufnr], {
          bufnr = bufnr,
          lnum = example.line_number,
          col = 1,
          severity = vim.diagnostic.severity.ERROR,
          source = "rspec-runner",
          message = example.exception.message,
          user_data = {},
        })
      end
    end

    if config.diagnostics then
      for bufnr, entries in pairs(failed) do
        vim.diagnostic.set(ns, bufnr, entries, {})
      end
    end

    if config.qflist then
      vim.diagnostic.setqflist({open = true, namespace = ns, title = "RSpec Failures" })
    end
  end

  return vim.system(
    utils.concat(config.cmd, runner:build_args()),
    { stdout = on_stdout },
    function() vim.schedule(on_exit) end
  )
end

return M
