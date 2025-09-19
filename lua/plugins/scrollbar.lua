return {
  'petertriho/nvim-scrollbar',
  -- Make sure the tokyonight plugin is loaded before scrollbar
  dependencies = { 'folke/tokyonight.nvim' },
  config = function()
    -- Get the colors from your tokyonight colorscheme
    local colors = require('tokyonight.colors').setup()

    -- Set up the scrollbar
    require('scrollbar').setup {
      handle = {
        color = colors.bg_highlight,
      },
      marks = {
        Search = { color = colors.orange },
        Error = { color = colors.error },
        Warn = { color = colors.warning },
        Info = { color = colors.info },
        Hint = { color = colors.hint },
        Misc = { color = colors.purple },
      },
    }
  end,
}
