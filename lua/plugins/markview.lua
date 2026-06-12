return {
  {
    'OXY2DEV/markview.nvim',
    lazy = false,
    dependencies = {
      'echasnovski/mini.icons',
    },
    opts = {
      markdown = {
        block_quotes = { wrap = true },
        headings = { org_indent_wrap = true },
        list_items = { wrap = true },
      },
    },
    config = function(_, opts)
      require('markview').setup(opts)

      -- Enable wrap for markdown files as requested
      vim.api.nvim_create_autocmd('FileType', {
        pattern = 'markdown',
        callback = function()
          vim.opt_local.wrap = true
          vim.opt_local.linebreak = true
        end,
      })
    end,
  },
}
