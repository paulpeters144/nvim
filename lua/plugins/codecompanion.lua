-- CodeCompanion
-- https://github.com/olimorris/codecompanion.nvim
-- Talks to opencode's hosted OpenAI-compatible API (Go subscription) through the
-- `opencode_go` adapter below. Requires the OPENCODE_GO_API_KEY env var.

local function opencode_adapter()
  return require('codecompanion.adapters').extend('openai_compatible', {
    formatted_name = 'OpenCode (Go)',
    env = {
      url = 'https://opencode.ai/zen/go', -- base URL; chat_url is appended below
      chat_url = '/v1/chat/completions',
      models_endpoint = '/v1/models', -- -> https://opencode.ai/zen/go/v1/models
      api_key = 'OPENCODE_GO_API_KEY', -- env var holding the Go key
    },
    headers = {
      ['x-opencode-session'] = 'codecompanion', -- stable session id for Go caching/routing
      ['User-Agent'] = 'codecompanion.nvim', -- Go prefers a non-generic user agent
    },
    schema = {
      model = {
        default = 'deepseek-v4.1-flash', -- bare Go model ID (no opencode-go/ prefix)
        choices = { 'deepseek-v4.1-flash', 'deepseek-v4-pro', 'deepseek-v4-flash' },
      },
    },
  })
end

-- Show a spinner via fidget while a CodeCompanion request is in flight, so it's
-- clear the model is working in the background.
local function fidget_progress()
  local progress = require 'fidget.progress'
  local handles = {}

  local function start(event)
    local data = event.data or {}
    if not data.id then
      return
    end
    local action = data.interaction == 'inline' and 'Inline edit' or 'Responding'
    handles[data.id] = progress.handle.create {
      title = (data.adapter or {}).model,
      message = action,
      lsp_client = { name = 'CodeCompanion' },
    }
  end

  local function finish(event)
    local id = (event.data or {}).id
    local handle = handles[id]
    if handle then
      handle:finish()
      handles[id] = nil
    end
  end

  vim.api.nvim_create_augroup('CodeCompanionFidget', { clear = true })
  vim.api.nvim_create_autocmd('User', {
    group = 'CodeCompanionFidget',
    pattern = 'CodeCompanionRequestStarted',
    callback = start,
  })
  vim.api.nvim_create_autocmd('User', {
    group = 'CodeCompanionFidget',
    pattern = 'CodeCompanionRequestFinished',
    callback = finish,
  })
end

return {
  {
    dir = '~/Documents/repo/codecompanion.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-treesitter/nvim-treesitter',
    },
    cmd = { 'CodeCompanion', 'CodeCompanionAsk', 'CodeCompanionEdit' },
    keys = {
      { '<leader>aa', 'V:CodeCompanionAsk<cr>', mode = 'n', desc = 'Ask' },
      { '<leader>aa', ':CodeCompanionAsk<cr>', mode = 'v', desc = 'Ask' },
      { '<leader>ae', 'V:CodeCompanionEdit<cr>', mode = 'n', desc = 'Edit' },
      { '<leader>ae', ':CodeCompanionEdit<cr>', mode = 'v', desc = 'Edit' },
    },
    config = function()
      require('codecompanion').setup {
        adapters = {
          http = {
            opencode_go = opencode_adapter,
          },
        },
        display = {
          chat = {
            window = {
              layout = 'float',
              border = 'rounded',
              relative = 'editor',
              width = { min = 40, max = 110 },
              height = 0.90,
            },
          },
        },
        interactions = {
          chat = {
            adapter = 'opencode_go',
            tools = { opts = { approval_mode = 'auto' } },
            keymaps = {
              close = {
                modes = { n = { '<C-c>', '<Esc>' }, i = '<C-c>' },
              },
            },
          },
          inline = {
            adapter = 'opencode_go',
            tools = {
              enabled = true,
              opts = { approval_mode = 'auto' },
            },
          },
        },
      }

      fidget_progress()
    end,
  },
}
