return {
  {
    'olimorris/codecompanion.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-treesitter/nvim-treesitter',
    },
    config = function()
      local selected_model = 'gemini-3-flash-preview'
      local adapter_name = 'Gemini 3 Flash'

      -- Dynamic adapter function
      local function get_adapter()
        return require('codecompanion.adapters').extend('gemini', {
          name = adapter_name,
          schema = {
            model = {
              default = selected_model,
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

      vim.keymap.set({ 'n', 'v' }, '<leader>ac', '<cmd>CodeCompanionChat Toggle<cr>', { desc = 'AI [C]hat' })
      vim.keymap.set({ 'n', 'v' }, '<leader>aa', '<cmd>CodeCompanionActions<cr>', { desc = 'AI [A]ctions' })

      -- AI Edit (Inline)
      vim.keymap.set('n', '<leader>ae', function()
        local line_num = vim.fn.line '.'
        vim.ui.input({ prompt = 'AI Edit (Line ' .. line_num .. '): ' }, function(input)
          if input and input ~= '' then
            vim.cmd('CodeCompanion #{buffer} At line ' .. line_num .. ': ' .. input)
          end
        end)
      end, { desc = 'AI [E]dit (Buffer)' })

      vim.keymap.set('v', '<leader>ae', '<cmd>CodeCompanion<cr>', { desc = 'AI [E]dit (Selection)' })

      -- AI Question (Chat)
      vim.keymap.set("n", "<leader>aq", function()
        local line_num = vim.fn.line(".")
        vim.ui.input({ prompt = "AI Question (Line " .. line_num .. "): " }, function(input)
          if input and input ~= "" then
            vim.cmd("CodeCompanionChat #{buffer} Regarding line " .. line_num .. ": " .. input)
          end
        end)
      end, { desc = "AI [Q]uestion (Buffer)" })

      vim.keymap.set('v', '<leader>aq', function()
        vim.ui.input({ prompt = 'AI Question (Selection): ' }, function(input)
          if input and input ~= '' then
            vim.cmd("'<,'>CodeCompanionChat " .. input)
          end
        end)
      end, { desc = 'AI [Q]uestion (Selection)' })

      local models = {
        { name = 'Gemini 3 Flash', model = 'gemini-3-flash-preview' },
        { name = 'Gemini 3 Pro', model = 'gemini-3-pro-preview' },
      }

      vim.keymap.set({ 'n', 'v' }, '<leader>as', function()
        vim.ui.select(models, {
          prompt = 'Select CodeCompanion Model:',
          format_item = function(item)
            return item.name
          end,
        }, function(choice)
          if choice then
            selected_model = choice.model
            adapter_name = choice.name
            vim.notify('Switched CodeCompanion model to ' .. adapter_name)
          end
        end)
      end, { desc = 'AI [S]witch Model' })
    end,
  },
}
