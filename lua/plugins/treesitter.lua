return {
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    config = function()
      local configs = require 'nvim-treesitter.config'

      vim.api.nvim_create_autocmd('FileType', {
        group = vim.api.nvim_create_augroup('treesitter-highlight', { clear = true }),
        callback = function(args)
          pcall(vim.treesitter.start, args.buf)
        end,
      })

      configs.setup {
        auto_install = true,
        indent = { enable = true },
        ensure_installed = {
          'go',
          'gomod',
          'gosum',
          'gowork',
          'typescript',
          'javascript',
          'tsx',
          'html',
          'css',
          'json',
          'lua',
          'rust',
          'c_sharp',
          'c',
          'yaml',
          'toml',
          'markdown',
          'markdown_inline',
          'regex',
          'vim',
          'vimdoc',
          'bash',
          'sql',
          'diff',
        },
        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection = '<C-space>',
            node_incremental = '<C-space>',
            scope_incremental = false,
            node_decremental = '<bs>',
          },
        },
        textobjects = {
          select = {
            enable = true,
            lookahead = true,
            keymaps = {
              ['af'] = '@function.outer',
              ['if'] = '@function.inner',
              ['ac'] = '@class.outer',
              ['ic'] = '@class.inner',
            },
          },
        },
      }
    end,
  },
  {
    'nvim-treesitter/nvim-treesitter-textobjects',
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
  },
}
