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

      if vim.fn.executable 'gh' == 0 then
        vim.notify('Octo.nvim requires the GitHub CLI (gh) to be installed.', vim.log.levels.WARN)
      end
    end,
  },
}
