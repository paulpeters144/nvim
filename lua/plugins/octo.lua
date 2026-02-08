return {
  {
    'pwntester/octo.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-telescope/telescope.nvim',
      'nvim-tree/nvim-web-devicons',
    },
    config = function()
      require('octo').setup {
        enable_builtin = true,
        use_local_fs = true, -- writes to local fs instead of memory for better performance
      }
      vim.keymap.set('n', '<leader>op', '<cmd>Octo pr list<CR>', { desc = 'List PRs (Octo)' })
      vim.keymap.set('n', '<leader>oi', '<cmd>Octo issue list<CR>', { desc = 'List Issues (Octo)' })
      vim.keymap.set('n', '<leader>od', '<cmd>Octo discussion list<CR>', { desc = 'List Discussions (Octo)' })
      vim.keymap.set('n', '<leader>on', '<cmd>Octo notification list<CR>', { desc = 'List Notifications (Octo)' })
      vim.keymap.set('n', '<leader>os', '<cmd>Octo search<CR>', { desc = 'Search (Octo)' })
      vim.keymap.set('n', '<leader>or', '<cmd>Octo repo list<CR>', { desc = 'List Repos (Octo)' })
      vim.keymap.set('n', '<leader>oa', '<cmd>Octo actions<CR>', { desc = 'List Actions (Octo)' })

      if vim.fn.executable 'gh' == 0 then
        vim.notify('Octo.nvim requires the GitHub CLI (gh) to be installed.', vim.log.levels.WARN)
      end
    end,
  },
}
