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
  local errors = {}
  local examples = {}
  local passed_count = 0
  local failed_count = 0

  notifier:run_start(runner.scope, runner.files)
  print(string.format("[RspecRunner][INFO]: Running in %s scope", runner.scope:upper()))

  local function on_stdout(err, data)
    if err then
      notifier:error("An error has occurred:\n" ..err)
      return
    end

    if data then
      output = output .. data
    end
  end

  local function on_stderr(err, data)
    if err then
      notifier:error("An error has occurred:\n" ..err)
      return
    elseif data then
      -- ignore deprecation warnings
      if string.match(data, "^DEPRECATION WARNING:") == nil then
        table.insert(errors, data)
      end
    end
  end

  local function on_exit()
    if #errors > 0 then
      print("[RspecRunner][DEBUG]: Run with command: `" .. vim.fn.join(runner.cmd, " ") .. "`")
      for _, line in pairs(errors) do
        print("[RspecRunner][ERROR]: " .. line)
      end
      print(string.format("[RspecRunner][ERROR]: %s errors.", #errors))
    end

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
      notifier:error("No examples found. Check messages for details.")
      return
    end

    local failed = {}

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

    for bufnr, entries in pairs(failed) do
      vim.diagnostic.set(ns, bufnr, entries, {})
    end

    if vim.tbl_isempty(failed) then
      notifier:run_passed(passed_count)
      print(string.format("[RspecRunner][INFO]: %s examples passed.", passed_count))
    else
      notifier:run_failed(failed_count)
      print(string.format("[RspecRunner][INFO]: %s examples failed.", failed_count))
    end

    state.output.examples = examples
    state.errors = errors
    state.output.passed_count = passed_count
    state.output.failed_count = failed_count
  end

  local job = vim.system(
    runner.cmd,
    { stdout = on_stdout, stderr = on_stderr },
    function() vim.schedule(on_exit) end
  )
  state.job = job

  return job
end

return M
