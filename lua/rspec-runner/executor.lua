local output = require("rspec-runner.output")

local M = {}

---@param runner Runner
---@param config Config
---@param state State
function M.execute(runner, config, state)
  local ns = config.namespace

  local notification = vim.notify(string.format("Running in scope: %s...", runner.cfg.scope))

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
      vim.notify("No examples.", vim.log.levels.ERROR, {
        replace = notification,
        title = "[RspecRunner]"
      })
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

    if vim.tbl_isempty(failed) then
      local summary = state.output.summary
      local successful = tonumber(summary.example_count) - tonumber(summary.failure_count) - tonumber(summary.pending_count)

      vim.notify(successful .. " passed", vim.log.levels.DEBUG, {
        replace = notification,
        title = "[RspecRunner]"
      })
    else
      local body = table.concat({
        state.output.summary.failure_count .. " failures",
      }, "\n")
      vim.notify(body, vim.log.levels.ERROR, {
        replace = notification,
        title = "[RspecRunner]"
      })
    end
  end

  return vim.system(
    runner.cmd,
    { stdout = on_stdout },
    function() vim.schedule(on_exit) end
  )
end

return M
