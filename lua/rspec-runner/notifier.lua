---@class Notifier
---@field settings table
local Notifier = {}

Notifier.__index = Notifier

---@param config Config
---@return Notifier
function Notifier.new(config)
  local self = setmetatable({}, Notifier)

  self.settings = {
    notify = config.notify,
    title = "[RspecRunner]",
    notification = nil
  }

  return self
end

---@param msg string
---@param level number? vim.log.levels
---@param opts table?
function Notifier:notify(msg, level, opts)
  if not self.settings.notify then
    return
  else
    opts = opts or {}
    local timeout
    if opts.timeout == false then
      timeout = false
    else
      timeout = opts.timeout or 3000
    end

    self.settings.notification = vim.notify(msg, level, {
      title = self.settings.title,
      timeout = timeout,
      replace = self.settings.notification
    })
  end
end

---@param scope Scope
---@param count? number number of files being tested
function Notifier:run_start(scope, count)
  local msg
  if count and count > 0 then
    msg = string.format("Running for %s files in %s scope...", count, scope:upper())
  else
    msg = string.format("Running in %s scope...", scope:upper())
  end

  self:notify(
    msg,
    vim.log.levels.INFO,
    { timeout = false }
  )
end

---@param count number
function Notifier:run_passed(count)
  self:notify(count .. " examples passed.", vim.log.levels.DEBUG)
end

---@param count number
function Notifier:run_failed(count)
  self:notify(count .. " examples failed.", vim.log.levels.ERROR)
end

---@param msg string
function Notifier:error(msg)
  self:notify(msg, vim.log.levels.ERROR)
end

function Notifier:run_cancelled()
  self:notify("Run cancelled", vim.log.levels.WARN)
end

function Notifier:run_in_progress()
  self:notify("Run already in progress...", vim.log.levels.WARN)
end

return Notifier
