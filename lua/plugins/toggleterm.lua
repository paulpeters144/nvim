return {
  {
    'akinsho/toggleterm.nvim',
    version = '*',
    opts = {
      open_mapping = [[<c-\>]], -- example: Ctrl + \
      -- other toggleterm setup options as needed
      -- for example:
      size = 20,
      direction = 'horizontal', -- or 'float' etc
      -- ...
    },
    config = function(_, opts)
      require('toggleterm').setup(opts)

      -- If you want to send current line or selection to a terminal:
      -- etc. for visual mappings, etc.
    end,
  },
}
