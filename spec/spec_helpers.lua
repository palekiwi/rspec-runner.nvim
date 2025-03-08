local M = {}

---@param path string
---@param line? number
function M.view_file(path, line)
  local cmd = ""
  if line == nil then
    cmd = string.format("view %s", path)
  else
    cmd = string.format("view +%s %s", line, path)
  end

  vim.api.nvim_command(cmd)
end

---@param filepath string
---@return string
function M.read_file(filepath)
  local file = io.open(filepath, "r")

  if not file then
    error("Error reading file.")
  else
    io.input(file)
    local result = io.read("*a")
    file:close()
    return result
  end
end

---@return Config
function M.build_config()
  return {
    cmd = { "rspec" },
    diagnostics = true,
    namespace = vim.api.nvim_create_namespace("rspec-runner"),
    notify = false,
    spec_patterns = { "_spec%.rb$" }
  }
end

return M
