return {
  {
    'stevearc/oil.nvim',
    dependencies = { { 'echasnovski/mini.icons', opts = {} } },
    lazy = false,
    opts = {
      keymaps = {
        ['<C-v>'] = false,
        ['<C-x>'] = false,
        ['<C-h>'] = false,
        ['<C-l>'] = false,
        ['<C-z>'] = { 'actions.select', opts = { horizontal = true } },
      },
      view_options = {
        show_hidden = true,
      },
    },
  },
}
