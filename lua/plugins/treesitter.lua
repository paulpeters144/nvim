return {
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    config = function()
      require('nvim-treesitter.configs').setup {
        ensure_installed = {
          'bash', 'c', 'diff', 'go', 'gomod', 'gosum', 'gowork',
          'html', 'lua', 'luadoc', 'markdown', 'markdown_inline',
          'query', 'rust', 'vim', 'vimdoc',
        },
        auto_install = true,
        highlight = { enable = true },
        indent = { enable = true },
      }
    end,
  },
}
