local has_telescope = pcall(require, "telescope")

if not has_telescope then
  error("This plugin requires nvim-telescope/telescope.nvim")
end

local actions = require('telescope.actions')
local actions_state = require('telescope.actions.state')
local finders = require('telescope.finders')
local pickers = require('telescope.pickers')
local previewers = require("telescope.previewers")
local telescope_cfg = require('telescope.config').values

local Previewer = require("rspec-runner.previewer")

local M = {}

---@param examples Output.Example[]
---@param config Config
function M.browse(examples, config)
  local opts = {}
  local ns = config.namespace

  ---@param entry Output.Example
  local function entry_maker(entry)
    return {
      value = entry,
      display = entry.full_description,
      ordinal = entry.id
    }
  end

  pickers.new({}, {
    finder = finders.new_table {
      results = vim.tbl_filter(function(ex) return ex.status == "failed" end, examples),
      entry_maker = entry_maker,
    },

    sorter = telescope_cfg.generic_sorter(opts),

    previewer = previewers.new_buffer_previewer {
      title = "[RspecRunner] Failures",
      define_preview = Previewer.telescope_previewer,
    },

    attach_mappings = function(prompt_bufnr, map)
      actions.select_default:replace(function()
        local selection = actions_state.get_selected_entry()
        actions.close(prompt_bufnr)

        local ln = selection.value.line_number
        local path = selection.value.file_path

        vim.api.nvim_command(string.format("e +%s %s", ln, path))
      end)

      map("i", "<C-q>", function(_)
        local ex = actions_state.get_selected_entry().value

        vim.diagnostic.reset(ns)

        actions.close(prompt_bufnr)

        local backtrace = {}

        for _, item in pairs(ex.exception.backtrace) do
          local file_path, line = string.match(item, "([^:]+):([^:]+):.*")
          local bufnr = vim.fn.bufnr(file_path, true)

          local entry = {
            bufnr = bufnr,
            lnum = tonumber(line) - 1,
            col = 1,
            severity = vim.diagnostic.severity.ERROR,
            source = "rspec-runner",
            message = "[RspecRunner] Backtrace: " .. ex.description,
            user_data = {},
          }

          backtrace[bufnr] = backtrace[bufnr] or {}
          table.insert(backtrace[bufnr], entry)
        end

        for bufnr, entries in pairs(backtrace) do
          vim.diagnostic.set(ns, bufnr, entries, {})
        end


        vim.diagnostic.setqflist({ open = true, namespace = ns, title = "[RspecRunner] Backtrace" })
      end, { desc = "Send backtrace qflist" })

      return true
    end,

  }):find()
end

return M
