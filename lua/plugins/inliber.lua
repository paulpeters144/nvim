-- Inliber
-- https://github.com/paulpeters144/inliber.nvim
-- Talks to opencode's hosted OpenAI-compatible API (Go subscription) through the
-- `opencode_go` adapter below. Requires the OPENCODE_GO_API_KEY env var.

local function opencode_adapter()
  return require('inliber.adapters').extend('openai_compatible', {
    formatted_name = 'OpenCode (Go)',
    env = {
      url = 'https://opencode.ai/zen/go', -- base URL; chat_url is appended below
      chat_url = '/v1/chat/completions',
      models_endpoint = '/v1/models', -- -> https://opencode.ai/zen/go/v1/models
      api_key = 'OPENCODE_GO_API_KEY', -- env var holding the Go key
    },
    headers = {
      ['x-opencode-session'] = 'inliber', -- stable session id for Go caching/routing
      ['User-Agent'] = 'inliber.nvim', -- Go prefers a non-generic user agent
    },
    schema = {
      model = {
        default = 'deepseek-v4.1-flash', -- bare Go model ID (no opencode-go/ prefix)
        choices = { 'deepseek-v4.1-flash', 'deepseek-v4-pro', 'deepseek-v4-flash' },
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
            opencode_go = opencode_adapter,
          },
        },
        display = {
          diff = {
            enabled = false,
          },
        },
        interactions = {
          inline = {
            adapter = 'opencode_go',
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
