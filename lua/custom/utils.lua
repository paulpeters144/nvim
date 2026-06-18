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

local function strip_oil_prefix(path)
  local oil_prefix = 'oil:///'
  if path:sub(1, #oil_prefix) == oil_prefix then
    path = path:sub(#oil_prefix + 1)
    path = path:gsub('^([A-Za-z])/', '%1:/')
  end
  return path
end

---Copy current buffer relative path to system clipboard
function M.copy_relative_path()
  local path = vim.fn.expand '%.'
  path = strip_oil_prefix(path)
  vim.fn.setreg('+', path)
  vim.notify('Copied relative path: ' .. path)
end

---Copy current buffer absolute path to system clipboard
function M.copy_absolute_path()
  local path = vim.fn.expand '%:p'
  path = strip_oil_prefix(path)
  vim.fn.setreg('+', path)
  vim.notify('Copied absolute path: ' .. path)
end

return M
