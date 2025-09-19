return {
  {
    'akinsho/toggleterm.nvim',
    version = '*',
    opts = {
      open_mapping = [[<c-\>]], -- example: Ctrl + \
      -- other toggleterm setup options as needed
      -- for example:
      size = 20,
      direction = 'float', -- or 'float' etc
      -- ...
    },
    config = function(_, opts)
      require('toggleterm').setup(opts)

      -- Also create your own custom keymap if you want something besides open_mapping
      vim.keymap.set('n', '<leader>tt', '<cmd>ToggleTerm<CR>', { desc = 'Toggle Terminal' })
      -- If you want to send current line or selection to a terminal:
      -- etc. for visual mappings, etc.
    end,
  },
}
