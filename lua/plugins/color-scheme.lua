return {
  -- 1. monokai-v2 (most feature-rich monokai fork)
  {
    'khoido2003/monokai-v2.nvim',
    lazy = false,
    priority = 1000,
    config = function()
      require('monokai-v2').setup { filter = 'pro' }
      vim.cmd.colorscheme 'monokai-v2'
    end,
  },

  -- 2. monokai-pro.nvim (popular monokai-pro)
  -- {
  --   'loctvl842/monokai-pro.nvim',
  --   lazy = false,
  --   priority = 1000,
  --   config = function()
  --     require('monokai-pro').setup { filter = 'pro' }
  --     vim.cmd.colorscheme 'monokai-pro'
  --   end,
  -- },

  -- 3. tender.vim
  -- {
  --   'jacoborus/tender.vim',
  --   lazy = false,
  --   priority = 1000,
  --   config = function()
  --     vim.cmd.colorscheme 'tender'
  --   end,
  -- },

  -- 4. onedarkpro.nvim (vivid variant)
  -- {
  --   'olimorris/onedarkpro.nvim',
  --   lazy = false,
  --   priority = 1000,
  --   config = function()
  --     require('onedarkpro').setup {
  --       styles = {
  --         types = 'NONE',
  --         methods = 'NONE',
  --         numbers = 'NONE',
  --         strings = 'NONE',
  --         comments = 'italic',
  --         keywords = 'bold,italic',
  --         functions = 'NONE',
  --         variables = 'NONE',
  --       },
  --       options = { cursorline = true, transparency = false, terminal_colors = true },
  --       plugins = { all = true, lsp_semantic_tokens = false },
  --       highlights = {},
  --     }
  --     vim.cmd.colorscheme 'onedark_vivid'
  --   end,
  -- },

  -- 5. bluloco.nvim
  -- {
  --   'uloco/bluloco.nvim',
  --   lazy = false,
  --   priority = 1000,
  --   dependencies = { 'rktjmp/lush.nvim' },
  --   config = function()
  --     require('bluloco').setup { style = 'dark', italics = true, terminal = false }
  --     vim.cmd.colorscheme 'bluloco'
  --   end,
  -- },

  -- 6. monokai.nvim (original)
  -- {
  --   'tanvirtin/monokai.nvim',
  --   lazy = false,
  --   priority = 1000,
  --   config = function()
  --     require('monokai').setup {}
  --     vim.cmd.colorscheme 'monokai'
  --   end,
  -- },

  -- 7. vim-monokai-tasty (current active)
  -- {
  --   'patstockwell/vim-monokai-tasty',
  --   lazy = false,
  --   priority = 1000,
  --   config = function()
  --     vim.cmd.colorscheme 'vim-monokai-tasty'
  --   end,
  -- },
}
