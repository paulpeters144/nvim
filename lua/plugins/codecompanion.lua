return {
  {
    'olimorris/codecompanion.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-treesitter/nvim-treesitter',
      'j-hui/fidget.nvim',
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

      vim.keymap.set({ 'n', 'v' }, '<leader>ac', '<cmd>CodeCompanionChat Toggle<cr>', { desc = 'AI [C]hat' })
      vim.keymap.set({ 'n', 'v' }, '<leader>ar', function()
        local bufs = vim.api.nvim_list_bufs()
        for _, buf in ipairs(bufs) do
          if vim.api.nvim_buf_is_valid(buf) and vim.api.nvim_get_option_value('filetype', { buf = buf }) == 'codecompanion' then
            vim.api.nvim_buf_delete(buf, { force = true })
          end
        end
        vim.cmd('CodeCompanionChat Add')
      end, { desc = 'AI [R]eset (Clear All)' })
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
      local function smart_chat(prompt, prefix, is_visual)
        -- Capture filetype before any window changes
        local source_ft = vim.bo.filetype
        local selection = nil

        if is_visual then
          -- Exit visual mode to update marks
          vim.cmd('normal! \27')
          local start_line = vim.fn.line "'<"
          local end_line = vim.fn.line "'>"
          if start_line > 0 and end_line > 0 then
            local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
            selection = table.concat(lines, '\n')
          end
        end

        vim.ui.input({ prompt = prompt }, function(input)
          if not input or input == '' then
            return
          end

          local chat_win = nil
          for _, win in ipairs(vim.api.nvim_list_wins()) do
            local buf = vim.api.nvim_win_get_buf(win)
            if vim.api.nvim_get_option_value('filetype', { buf = buf }) == 'codecompanion' then
              chat_win = win
              break
            end
          end

          local final_input = (prefix or '') .. input

          if chat_win then
            vim.api.nvim_set_current_win(chat_win)
            local chat_buf = vim.api.nvim_win_get_buf(chat_win)

            local lines_to_add = { '', '---', '' }
            if selection then
              table.insert(lines_to_add, '```' .. source_ft)
              for _, line in ipairs(vim.split(selection, '\n')) do
                table.insert(lines_to_add, line)
              end
              table.insert(lines_to_add, '```')
              table.insert(lines_to_add, '')
            end
            table.insert(lines_to_add, final_input)

            local last_line = vim.api.nvim_buf_line_count(chat_buf)
            vim.api.nvim_buf_set_lines(chat_buf, last_line, last_line, false, lines_to_add)
            vim.api.nvim_win_set_cursor(chat_win, { vim.api.nvim_buf_line_count(chat_buf), 0 })

            -- Submit using <C-s> in Normal mode
            vim.schedule(function()
              vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<C-s>', true, false, true), 'm', false)
            end)
          else
            if is_visual then
              -- Since we exited visual mode, marks are set for the current selection
              vim.cmd("'<,'>CodeCompanionChat " .. final_input)
            else
              vim.cmd('CodeCompanionChat #{buffer} ' .. final_input)
            end

            -- Attempt to auto-submit if the command didn't
            vim.defer_fn(function()
              vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<C-s>', true, false, true), 'm', false)
            end, 300)
          end
        end)
      end

      vim.keymap.set('n', '<leader>aq', function()
        local line_num = vim.fn.line '.'
        smart_chat('AI Question (Line ' .. line_num .. '): ', 'Regarding line ' .. line_num .. ': ', false)
      end, { desc = 'AI [Q]uestion (Buffer)' })

      vim.keymap.set('v', '<leader>aq', function()
        smart_chat('AI Question (Selection): ', nil, true)
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
