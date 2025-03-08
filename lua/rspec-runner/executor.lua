local Notifier = require("rspec-runner.notifier")
local Decoder = require("rspec-runner.decoder")

local M = {}

---@param runner Runner
---@param config Config
---@param state State
function M.execute(runner, config, state)
  local ns = config.namespace

  local notifier = Notifier.new(config)

  local output = ""
  local examples = {}
  notifier:run_start(runner.scope)

  local function on_stdout(err, data)
    if err then
      notifier:error("An error has occurred:\n" ..err)
      return
    end

    -- local result

    -- if data then
    --   err, result = Decoder.decode(data)

    --   if err then
    --     notifier:error("A parsing error has occurred.")
    --   else
    --     vim.list_extend(examples, result)
    --   end
    -- end
    if data then
      output = output .. data
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

    local err, result = Decoder.decode(output)

    if err then
      notifier:error("A parsing error has occurred.")
    else
      vim.list_extend(examples, result)
    end

    if #examples == 0 then
      notifier:error("No examples")
      return
    end

    local failed = {}
    local passed_count = 0
    local failed_count = 0

    vim.api.nvim_buf_clear_namespace(0, ns, 0, -1)
    vim.diagnostic.reset(ns)

    for _, example in ipairs(examples) do
      local bufnr = vim.fn.bufnr(example.file_path, true)

      if example.status == "failed" then
        failed_count = failed_count + 1
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
      elseif example.status == "passed" then
        passed_count = passed_count + 1
      end
    end

    if config.diagnostics then
      for bufnr, entries in pairs(failed) do
        vim.diagnostic.set(ns, bufnr, entries, {})
      end
    end

    if vim.tbl_isempty(failed) then
      notifier:run_passed(passed_count)
    else
      notifier:run_failed(failed_count)
    end
  end

  local job = vim.system(
    runner.cmd,
    { stdout = on_stdout },
    function() vim.schedule(on_exit) end
  )

  state.output.examples = examples
  state.job = job

  return job
end

return M
