return {
  {
    'pwntester/octo.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-telescope/telescope.nvim',
    },
    config = function()
      require('octo').setup {
        picker = 'telescope',
        enable_builtin = true,
        use_local_fs = true, -- writes to local fs instead of memory for better performance
        file_panel = {
          icons = false, -- disabled because nvim-web-devicons is not enabled
        },
      }

      if vim.fn.executable 'gh' == 0 then
        vim.notify('Octo.nvim requires the GitHub CLI (gh) to be installed.', vim.log.levels.WARN)
      end
    end,
  },
}
