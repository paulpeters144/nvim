return {
  'sindrets/diffview.nvim',
  dependencies = { 'nvim-lua/plenary.nvim' },
  config = function()
    require('diffview').setup()
  end,
  keys = {
    { '<leader>gd', '<cmd>DiffviewOpen<cr>', desc = 'Diffview Open' },
    { '<leader>gh', '<cmd>DiffviewFileHistory %<cr>', desc = 'Diffview File History' },
    { '<leader>gc', '<cmd>DiffviewClose<cr>', desc = 'Diffview Close' },
  },
}
