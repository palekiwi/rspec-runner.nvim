vim.opt.runtimepath:append("/nix/store/qs9d8dnql2zqlqwn9ys4ajks8znlj7mj-vimplugin-nvim-treesitter-2024-11-13")
vim.opt.runtimepath:append("/nix/store/zfspdvjmlxhgi4z0pdwj795nz23sg9g8-vimplugin-treesitter-grammar-ruby")

---@diagnostic disable: missing-fields
require("nvim-treesitter.configs").setup {}

return true
