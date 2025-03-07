local output = require("rspec-runner.output")
local Notifier = require("rspec-runner.notifier")

local M = {}

---@param runner Runner
---@param config Config
---@param state State
function M.execute(runner, config, state)
  local ns = config.namespace

  local notifier = Notifier.new(config)

  notifier:run_start(runner.scope)

  local function on_stdout(err, data)
    if err then
      notifier:error("An error has occurred:\n" ..err)
      return
    end

    if data then
      local ok, valid_output = pcall(output.parse_json, data)

      if not ok then
        notifier:error("A parsing error has occurred.")
      elseif valid_output ~= nil then
        state.output = valid_output
      end
    end
  end

  local function on_exit()
    -- check if the run has been cancelled
    if state.job:is_closing() then
      local status = state.job:wait()
      if status.code > 2 then
        notifier:run_cancelled()
        return
      end
    end

    if #state.output.examples == 0 then
      notifier:error("No examples")
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
      notifier:run_passed(state.output.summary)
    else
      notifier:run_failed(state.output.summary)
    end
  end

  local job = vim.system(
    runner.cmd,
    { stdout = on_stdout },
    function() vim.schedule(on_exit) end
  )

  state.job = job

  return job
end

return M
