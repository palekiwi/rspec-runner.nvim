-- Runtimepath setup for the headless busted suite.
--
-- Only the ruby treesitter PARSER is required here: `Runner.find_nearest`
-- calls `vim.treesitter.get_parser(bufnr, "ruby")` (core nvim API), which
-- resolves `parser/ruby.so` from the runtimepath. The `nvim-treesitter`
-- plugin is NOT needed at runtime - in nvim 0.12 it is a parser installer
-- only, and the legacy `require("nvim-treesitter.parsers").get_parser` /
-- `require("nvim-treesitter.configs").setup{}` APIs have been removed.
-- Pinning the grammar here keeps the suite self-contained without masking
-- the production code path the way the previous nvim-treesitter pin did.
vim.opt.runtimepath:append("/nix/store/zfspdvjmlxhgi4z0pdwj795nz23sg9g8-vimplugin-treesitter-grammar-ruby")
vim.opt.runtimepath:append("/nix/store/g4jghf21rfbn7hg8mw8pxr8wdg5i4hxk-vimplugin-lua5.1-telescope.nvim-scm-1-unstable-2024-10-29")

return true
