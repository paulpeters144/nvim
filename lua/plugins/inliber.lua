-- Inliber
-- https://github.com/paulpeters144/inliber.nvim
-- Uses OpenCode through the Agent Client Protocol (ACP), with
-- DeepSeek V4.1 Flash (opencode-go/deepseek-v4.1-flash) as the model.

local function opencode_adapter()
  return require('inliber.adapters').extend('opencode', {
    defaults = {
      session_config_options = {
        model = 'opencode-go/deepseek-v4.1-flash',
      },
    },
  })
end

return {
  {
    -- Use the local checkout (contains the ACP refactor) instead of pulling
    -- from GitHub
    dir = 'C:/Users/paulp/Documents/repo/inliber.nvim',
    name = 'inliber.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-treesitter/nvim-treesitter',
    },
    cmd = { 'InliberAsk', 'InliberEdit', 'InliberAskResume' },
    keys = {
      { '<leader>aa', 'V:InliberAsk<cr>', mode = 'n', desc = 'Ask' },
      { '<leader>aa', ':InliberAsk<cr>', mode = 'v', desc = 'Ask' },
      { '<leader>ae', 'V:InliberEdit<cr>', mode = 'n', desc = 'Edit' },
      { '<leader>ae', ':InliberEdit<cr>', mode = 'v', desc = 'Edit' },
      { '<leader>ar', '<cmd>InliberAskResume<cr>', mode = 'n', desc = 'Resume Ask' },
    },
    config = function()
      require('inliber').setup {
        adapters = {
          acp = {
            opencode = opencode_adapter,
          },
        },
        display = {
          diff = {
            enabled = false,
          },
        },
        interactions = {
          inline = {
            adapter = 'opencode',
          },
        },
      }
    end,
  },
}
