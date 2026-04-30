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
M.ai_selected_model = 'gemini-3-flash-preview'
M.ai_adapter_name = 'Gemini 3 Flash'

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
  -- Capture filetype and buffer content before any window changes
  local source_ft = vim.bo.filetype
  local source_buf = vim.api.nvim_get_current_buf()
  local selection = nil

  if is_visual then
    -- Exit visual mode to update marks
    vim.cmd('normal! \27')
    local start_line = vim.fn.line "'<"
    local end_line = vim.fn.line "'>"
    if start_line > 0 and end_line > 0 then
      local lines = vim.api.nvim_buf_get_lines(source_buf, start_line - 1, end_line, false)
      selection = table.concat(lines, '\n')
    end
  end

  local full_buffer = table.concat(vim.api.nvim_buf_get_lines(source_buf, 0, -1, false), '\n')

  vim.ui.input({ prompt = prompt }, function(input)
    if not input then
      return
    end

    if input == '' then
      input = 'Explain'
    end
    input = (prefix or '') .. input

    local chat_win = nil
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      local buf = vim.api.nvim_win_get_buf(win)
      if vim.api.nvim_get_option_value('filetype', { buf = buf }) == 'codecompanion' then
        chat_win = win
        break
      end
    end

    local final_input = input

    if chat_win then
      vim.api.nvim_set_current_win(chat_win)
      local chat_buf = vim.api.nvim_win_get_buf(chat_win)

      local lines_to_add = { '', '---', '' }

      if is_visual and selection then
        table.insert(lines_to_add, 'Selection:')
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
        vim.cmd("'<,'>CodeCompanionChat #{buffer} " .. final_input)
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

---AI Edit: unified edit function with buffer context and selection awareness
function M.ai_edit(is_visual)
  local start_line, end_line
  if is_visual then
    -- Exit visual mode to update marks
    vim.cmd 'normal! \27'
    start_line = vim.fn.line "'<"
    end_line = vim.fn.line "'>"
  else
    start_line = vim.fn.line '.'
    end_line = start_line
  end

  -- Ensure we have a valid range
  if start_line == 0 or end_line == 0 then
    start_line = vim.fn.line '.'
    end_line = start_line
  end

  local prompt_label = is_visual and 'AI Edit (Selection): ' or ('AI Edit (Line ' .. start_line .. '): ')

  vim.ui.input({
    prompt = prompt_label,
    default = '',
  }, function(input)
    if not input then
      return
    end

    if input == '' then
      input = 'implement'
    end

    local final_prompt = input .. ' (Return the code in a markdown code block. Match indentation. Return COMPLETE functions/blocks)'
    local range = start_line == end_line and tostring(start_line) or (start_line .. ',' .. end_line)

    vim.cmd(range .. 'CodeCompanion #{buffer} ' .. final_prompt)
  end)
end

---Copy current buffer relative path to system clipboard
function M.copy_relative_path()
  local path = vim.fn.expand '%:.'
  vim.fn.setreg('+', path)
  vim.notify('Copied relative path: ' .. path)
end

---Copy current buffer absolute path to system clipboard
function M.copy_absolute_path()
  local path = vim.fn.expand '%:p'
  vim.fn.setreg('+', path)
  vim.notify('Copied absolute path: ' .. path)
end

return M
