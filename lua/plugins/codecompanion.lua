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

      -- Dynamic adapter function
      local function get_adapter()
        return require('codecompanion.adapters').extend('gemini', {
          url = 'https://generativelanguage.googleapis.com/v1beta/openai/chat/completions',
          schema = {
            model = {
              default = utils.ai_selected_model,
            },
          },
        })
      end

      require('codecompanion').setup {
        strategies = {
          chat = {
            adapter = get_adapter,
          },
          inline = {
            adapter = get_adapter,
          },
        },
      }

      -- Fidget integration
      local progress = require('fidget.progress')
      local progress_handle = nil

      vim.api.nvim_create_autocmd('User', {
        pattern = 'CodeCompanionRequestStarted',
        callback = function()
          if progress_handle then
            progress_handle.message = 'Thinking...'
          else
            progress_handle = progress.handle.create({
              title = 'CodeCompanion',
              message = 'Thinking...',
              lsp_client = { name = 'Gemini' },
              percentage = 0,
            })
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
