local utils = require("telescope.previewers.utils")

local M = {}

function M.telescope_previewer(self, entry)
  local ex = entry.value
  local bufnr = self.state.bufnr

  vim.api.nvim_buf_set_lines(bufnr, 0, 0, true,
    vim.iter({
      "# " .. ex.full_description,
      "",

      "```rb",
      ex.exception.class,
      vim.split(ex.exception.message, "\n"),
      "```",
      "",

      "## Backtrace",
      ex.exception.backtrace,
    }):flatten():totable()
  )

  utils.highlighter(bufnr, "markdown")
end

return M
