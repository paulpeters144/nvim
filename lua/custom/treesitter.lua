-- Built-in tree-sitter configuration (no external plugins)
-- Query files are in ~/.config/nvim/queries/ (copied from nvim-treesitter)

-- Enable tree-sitter highlighting for all filetypes
vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('treesitter-highlight', { clear = true }),
  callback = function(args)
    pcall(vim.treesitter.start, args.buf)
  end,
})
