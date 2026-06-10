return {
  'leoluz/nvim-dap-go',
  ft = { 'go' },
  dependencies = {
    'mfussenegger/nvim-dap',
    'nvim-neotest/nvim-nio',
  },
  opts = {
    delve = {
      detached = vim.fn.has 'win32' == 0,
      path = vim.fn.stdpath 'data' .. '/mason/packages/delve/dlv.exe',
      args = { '--check-go-version=false' },
    },
  },
  keys = {
    {
      '<leader>lgt',
      function()
        require('dap-go').debug_test()
      end,
      desc = 'Debug [T]est at cursor',
    },
    {
      '<leader>lgT',
      function()
        require('dap-go').debug_last()
      end,
      desc = 'Debug Last [T]est',
    },
  },
  config = function(_, opts)
    require('dap-go').setup(opts)
  end,
}
