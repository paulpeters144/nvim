return {
  {
    'neko-night/nvim',
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd.colorscheme 'nekonight-storm'
    end,
  },
}
