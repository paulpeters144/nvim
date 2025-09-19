return {
  {
    'L3MON4D3/LuaSnip',
    config = function()
      require('luasnip.loaders.from_vscode').lazy_load() -- load friendly-snippets by default
    end,
  },
  {
    'rafamadriz/friendly-snippets',
    dependencies = { 'L3MON4D3/LuaSnip' },
    config = function()
      -- Load official snippets (friendly-snippets)
      require('luasnip.loaders.from_vscode').lazy_load()

      -- Load *your* custom snippets
      require('luasnip.loaders.from_vscode').lazy_load {
        paths = { vim.fn.stdpath 'config' .. '/snippets' },
      }
    end,
  },
}
