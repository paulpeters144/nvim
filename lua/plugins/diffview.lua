return {
  'sindrets/diffview.nvim',
  dependencies = { 'nvim-lua/plenary.nvim' },
  config = function()
    require('diffview').setup()
  end,
  keys = {
    { '<leader>gd', '<cmd>DiffviewOpen<cr>', desc = 'Open [D]iff View' },
    { '<leader>gh', '<cmd>DiffviewFileHistory %<cr>', desc = 'File [H]istory' },
    { '<leader>gc', '<cmd>DiffviewClose<cr>', desc = '[C]lose Diff View' },
  },
}
