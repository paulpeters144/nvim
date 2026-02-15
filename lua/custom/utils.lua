local M = {}

---Clear search highlights and close all floating windows
function M.clear_ui()
  vim.cmd 'nohlsearch'
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local config = vim.api.nvim_win_get_config(win)
    if config.relative ~= '' then
      vim.api.nvim_win_close(win, false)
    end
  end
end

---Smart buffer delete: prompt for save if modified
function M.smart_buf_delete()
  local bd = require('mini.bufremove').delete
  if vim.bo.modified then
    local choice = vim.fn.confirm(('Save changes to %q?'):format(vim.fn.bufname()), "&Yes\n&No\n&Cancel")
    if choice == 1 then
      vim.cmd.write()
      bd(0, false)
    elseif choice == 2 then
      bd(0, true)
    end
  else
    bd(0, false)
  end
end

-- CodeCompanion Model State
M.ai_selected_model = 'gemini-2.0-flash'
M.ai_adapter_name = 'Gemini 2.0 Flash'

local models = {
  { name = 'Gemini 3 Flash', model = 'gemini-3-flash-preview' },
  { name = 'Gemini 3 Pro', model = 'gemini-3-pro-preview' },
  { name = 'Gemini 2.0 Flash', model = 'gemini-2.0-flash' },
  { name = 'Gemini 2.0 Flash Thinking', model = 'gemini-2.0-flash-thinking-exp' },
  { name = 'Gemini 1.5 Pro', model = 'gemini-1.5-pro' },
  { name = 'Gemini 1.5 Flash', model = 'gemini-1.5-flash' },
}

---Switch CodeCompanion model
function M.ai_switch_model()
  vim.ui.select(models, {
    prompt = 'Select CodeCompanion Model:',
    format_item = function(item)
      return item.name
    end,
  }, function(choice)
    if choice then
      M.ai_selected_model = choice.model
      M.ai_adapter_name = choice.name
      vim.notify('Switched CodeCompanion model to ' .. M.ai_adapter_name)
    end
  end)
end

---Smart chat: toggle or create chat with selection/context
function M.smart_chat(prompt, prefix, is_visual)
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

return M
