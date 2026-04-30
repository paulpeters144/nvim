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

      local function get_inline_adapter()
        return require('codecompanion.adapters').extend('gemini', {
          env = {
            api_key = 'GEMINI_API_KEY',
          },
          schema = {
            model = {
              default = 'gemini-3-flash-preview',
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
            opts = {
              system_prompt = [[You are a senior software engineer.
Focus your response ONLY on the user's question or the specific task requested.
Use the provided buffer context ONLY to inform your answer.
DO NOT echo the context or return the entire file unless explicitly asked.
If providing a code snippet, include ONLY the relevant portion.
DO NOT provide any follow-up questions, suggestions, or 'example direction prompts' like 'Do you want to explore...', 'Would you prefer to...', or 'What would you like to do next?'.
Stop immediately after your response.]],
            },
          },
          inline = {
            adapter = get_inline_adapter,
            opts = {
              system_prompt = [[You are a senior software engineer acting as an inline assistant.
Provide ONLY the code or text to be inserted or replaced.
DO NOT include markdown formatting (unless specifically requested), conversational filler, or the surrounding file context.
Your output will be used to directly modify the buffer, so it must be surgical and precise.
DO NOT return the entire file; only return the specific modification.
Stop immediately after your response.]],
            },
          },
        },
        opts = {
          system_prompt = [[You are a senior software engineer.
Just answer the user's question or perform the requested task.
Focus your response ONLY on the question and then stop immediately.
DO NOT echo the context or return the entire file.
No conversational filler or guiding questions after the primary response.]],
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
