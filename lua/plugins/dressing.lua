return {
  { -- Neovim vim.ui.input / vim.ui.select override with nice floating windows
    'stevearc/dressing.nvim',
    lazy = true,
    init = function()
      ---@diagnostic disable-next-line: duplicate-set-field
      vim.ui.input = function(...)
        require('lazy').load({ plugins = { 'dressing.nvim' } })
        return vim.ui.input(...)
      end
    end,
    opts = {
      input = {
        enabled = true,
        border = 'rounded',
        relative = 'cursor',
        prefer_width = 40,
        min_width = { 20, 0.2 },
        max_width = { 140, 0.9 },
        title = ' CodeCompanion ',
        title_pos = 'center',
      },
      select = { enabled = false },
    },
  },
}
