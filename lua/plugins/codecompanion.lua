return {
  {
    'olimorris/codecompanion.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-treesitter/nvim-treesitter',
      'j-hui/fidget.nvim',
    },
    config = function()
      local utils = require 'custom.utils'

      -- Using the gemini adapter which matches the Google endpoint's response format
      local function get_adapter()
        return require('codecompanion.adapters').extend('gemini', {
          env = {
            api_key = 'GEMINI_API_KEY',
          },
          schema = {
            model = {
              default = utils.ai_selected_model,
            },
          },
        })
      end

      require('codecompanion').setup {
        display = {
          chat = {
            window = {
              layout = 'float', -- Use floating layout
              relative = 'editor',
              width = math.min(120, math.floor(vim.o.columns * 0.9)),
              height = math.floor(vim.o.lines * 0.8),
              row = math.floor((vim.o.lines - math.floor(vim.o.lines * 0.8)) / 2),
              col = math.floor((vim.o.columns - math.min(120, math.floor(vim.o.columns * 0.9))) / 2),
              border = 'rounded',
              opts = {
                breakindent = true,
                linebreak = true,
                wrap = true,
              },
            },
          },
          diff = {
            enabled = false,
          },
        },
        strategies = {
          chat = {
            adapter = get_adapter,
          },
          inline = {
            adapter = get_adapter,
          },
        },
        opts = {
          system_prompt = [[You are a versatile AI assistant for developers.
Your goal is to help the developer understand, write, and refactor code effectively.

When providing code:
1. Ensure correctness and follow the project's style.
2. Always return complete, functional code blocks unless a snippet is specifically requested.
3. Match the file's indentation and naming conventions.

When explaining:
1. Be concise but thorough.
2. Focus on the "why" as much as the "how".

General Rules:
1. DO NOT suggest the next prompt.]],
        },
      }

      -- Fidget integration
      local progress = require 'fidget.progress'
      local progress_handle = nil

      vim.api.nvim_create_autocmd('User', {
        pattern = 'CodeCompanionRequestStarted',
        callback = function()
          if progress_handle then
            progress_handle.message = 'Thinking...'
          else
            progress_handle = progress.handle.create {
              title = 'CodeCompanion',
              message = 'Thinking...',
              lsp_client = { name = 'Gemini' },
              percentage = 0,
            }
          end
        end,
      })

      vim.api.nvim_create_autocmd('User', {
        pattern = 'CodeCompanionRequestFinished',
        callback = function()
          if progress_handle then
            progress_handle:finish()
            progress_handle = nil
          end
        end,
      })
    end,
  },
}
