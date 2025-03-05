vim.opt.runtimepath:append("/nix/store/qs9d8dnql2zqlqwn9ys4ajks8znlj7mj-vimplugin-nvim-treesitter-2024-11-13")
vim.opt.runtimepath:append("/nix/store/zfspdvjmlxhgi4z0pdwj795nz23sg9g8-vimplugin-treesitter-grammar-ruby")
vim.opt.runtimepath:append("/nix/store/g4jghf21rfbn7hg8mw8pxr8wdg5i4hxk-vimplugin-lua5.1-telescope.nvim-scm-1-unstable-2024-10-29")

---@diagnostic disable: missing-fields
require("nvim-treesitter.configs").setup {}

return true
