-- Inliber
-- https://github.com/paulpeters144/inliber.nvim
-- Grok speaks ACP itself: `grok agent stdio` (JSON-RPC on stdin/stdout).
-- Inliber cancels tool-permission prompts, so the process is started
-- with --always-approve. Auth uses the cached `grok login` token.

local function opencode_adapter()
  return require('inliber.adapters').extend('opencode', {
    defaults = {
      session_config_options = {
        model = 'opencode-go/deepseek-v4.1-flash',
      },
    },
  })
end

local function grok_adapter()
  local helpers = require('inliber.adapters.acp.helpers')
  return {
    name = 'grok',
    formatted_name = 'Grok',
    type = 'acp',
    roles = {
      llm = 'assistant',
      user = 'user',
    },
    commands = {
      default = {
        'grok',
        'agent',
        '--always-approve',
        '--model',
        'grok-4.7-build-fast',
        'stdio',
      },
    },
    defaults = {
      auth_method = 'cached_token',
      mcpServers = {},
      timeout = 20000,
      session_config_options = {
        model = 'grok-4.7-build-fast',
        thought_level = 'low',
      },
    },
    parameters = {
      protocolVersion = 1,
      clientCapabilities = {
        fs = { readTextFile = true, writeTextFile = true },
      },
      clientInfo = {
        name = 'Inliber.nvim',
        version = '1.0.0',
      },
    },
    handlers = {
      setup = function()
        return true
      end,
      form_messages = function(self, messages, capabilities)
        return helpers.form_messages(self, messages, capabilities)
      end,
      on_exit = function() end,
    },
  }
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
            grok = grok_adapter,
          },
        },
        display = {
          diff = {
            enabled = false,
          },
        },
        interactions = {
          inline = {
            adapter = 'grok',
          },
        },
      }
    end,
  },
}
