return {
  {
    'NeogitOrg/neogit',
    dependencies = {
      'nvim-lua/plenary.nvim', -- required
      'nvim-telescope/telescope.nvim', -- optional
    },
    config = function()
      require('neogit').setup {
        integrations = {
          diffview = true,
          telescope = true,
        },
      }
    end,
    keys = {
      { '<leader>gg', '<cmd>Neogit<cr>', desc = 'Neogit (Full UI)' },
      { '<leader>gs', '<cmd>Telescope git_status<cr>', desc = 'Git [S]tatus (Telescope)' },
    },
  },
}
