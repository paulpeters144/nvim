-- Inliber
-- https://github.com/paulpeters144/inliber.nvim
-- Talks to Anthropic's API directly through the `claude` adapter below. Requires
-- the ANTHROPIC_API_KEY env var.

local function claude_adapter()
  return require('inliber.adapters').extend('anthropic', {
    schema = {
      model = {
        default = 'claude-haiku-4-5',
        choices = {
          ['claude-sonnet-5'] = {
            formatted_name = 'Claude Sonnet 5',
            meta = { context_window = 200000, max_tokens = 64000 },
            opts = { can_reason = true, has_vision = true },
          },
          ['claude-haiku-4-5'] = {
            formatted_name = 'Claude Haiku 4.5',
            meta = { context_window = 200000, max_tokens = 64000 },
            opts = { can_reason = true, has_vision = true },
          },
        },
      },
    },
  })
end

return {
  {
    'paulpeters144/inliber.nvim',
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
          http = {
            claude = claude_adapter,
          },
        },
        display = {
          diff = {
            enabled = false,
          },
        },
        interactions = {
          inline = {
            adapter = 'claude',
            tools = {
              enabled = true,
              opts = { approval_mode = 'auto' },
            },
          },
        },
      }
    end,
  },
}
