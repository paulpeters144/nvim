local utils = require 'custom.utils'

-- [[ Basic Keymaps ]]
vim.keymap.set('n', '<Esc>', utils.clear_ui, { desc = 'Clear search highlights and floating windows' })
vim.keymap.set('n', '-', '<cmd>Oil<cr>', { desc = 'Open parent directory' })
vim.keymap.set('n', 'Y', 'yy', { desc = 'Yank whole line' })

-- Diagnostics
vim.keymap.set('n', '<leader>e', function()
  vim.diagnostic.open_float { focus = true, scope = 'line' }
  -- If focus is still not working, try a second attempt with a small delay
  vim.defer_fn(function()
    vim.diagnostic.open_float { focus = true, scope = 'line' }
  end, 100)
end, { desc = 'Show line [E]rror diagnostics' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

-- [[ Movement & Visual ]]
vim.keymap.set('n', '<C-d>', '<C-d>zz', { desc = 'Scroll down and center' })
vim.keymap.set('n', '<C-u>', '<C-u>zz', { desc = 'Scroll up and center' })
vim.keymap.set('n', '<C-f>', '<C-f>zz', { desc = 'Page down and center' })
vim.keymap.set('n', '<C-b>', '<C-b>zz', { desc = 'Page up and center' })
vim.keymap.set('n', '<C-b>', '<C-v>', { desc = 'Visual block mode' })

-- [[ Window Navigation ]]
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- [[ Window Management ]]
vim.keymap.set('n', '<leader>wr', '<C-w>=', { desc = '[W]indow [R]ealign' })
vim.keymap.set('n', '<leader>wv', '<C-w>v', { desc = '[W]indow [V]ertical split' })
vim.keymap.set('n', '<leader>wh', '<C-w>s', { desc = '[W]indow [H]orizontal split' })
vim.keymap.set('n', '<leader>wd', '<C-w>c<C-w>=', { desc = '[W]indow [D]elete' })

-- [[ Buffer Management ]]
vim.keymap.set('n', '<leader>bn', '<cmd>bnext<cr>', { desc = '[B]uffer [N]ext' })
vim.keymap.set('n', '<leader>bp', '<cmd>bprevious<cr>', { desc = '[B]uffer [P]revious' })
vim.keymap.set('n', '<leader>bl', '<cmd>b#<cr>', { desc = '[B]uffer [L]ast' })
vim.keymap.set('n', '<leader>bd', utils.smart_buf_delete, { desc = '[B]uffer [D]elete' })
vim.keymap.set('n', '<leader>bq', '<cmd>bufdo bdelete<cr>', { desc = '[B]uffer [Q]uit all others' })
vim.keymap.set('n', '<leader>by', utils.copy_relative_path, { desc = '[B]uffer [Y]ank path' })
vim.keymap.set('n', '<S-h>', function()
  require('telescope.builtin').buffers(require('telescope.themes').get_ivy {
    sort_mru = true,
    sort_lastused = false,
    path_display = { 'smart' },
    initial_mode = 'normal',
    layout_config = {
      height = 45,
      preview_width = 0.45,
    },
    attach_mappings = function(_, map)
      local actions = require 'telescope.actions'
      map('n', 'd', actions.delete_buffer)
      return true
    end,
  })
end, { desc = 'Open [B]uffers (Telescope)' })

-- [[ Terminal ]]
vim.keymap.set('n', '<leader>tt', '<cmd>ToggleTerm<cr>', { desc = '[T]oggle [T]erminal' })
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- [[ Session Management ]]
vim.keymap.set('n', '<leader>qs', function()
  require('persistence').load()
end, { desc = '[Q]uick [S]ession load' })
vim.keymap.set('n', '<leader>qS', function()
  require('persistence').select()
end, { desc = '[Q]uick [S]ession select' })
vim.keymap.set('n', '<leader>ql', function()
  require('persistence').load { last = true }
end, { desc = '[Q]uick [L]ast session' })
vim.keymap.set('n', '<leader>qd', function()
  require('persistence').stop()
end, { desc = '[Q]uick [D]elete session' })

-- [[ Search (Telescope) ]]
vim.keymap.set('n', '<leader>sh', function()
  require('telescope.builtin').help_tags()
end, { desc = '[S]earch [H]elp' })
vim.keymap.set('n', '<leader>sk', function()
  require('telescope.builtin').keymaps()
end, { desc = '[S]earch [K]eymaps' })
vim.keymap.set('n', '<leader>ss', function()
  require('telescope.builtin').builtin()
end, { desc = '[S]earch [S]elect Telescope' })
vim.keymap.set('n', '<leader>sw', function()
  require('telescope.builtin').grep_string()
end, { desc = '[S]earch current [W]ord' })
vim.keymap.set('n', '<leader>sg', function()
  require('telescope.builtin').live_grep()
end, { desc = '[S]earch by [G]rep' })
vim.keymap.set('n', '<leader>sd', function()
  require('telescope.builtin').diagnostics()
end, { desc = '[S]earch [D]iagnostics' })
vim.keymap.set('n', '<leader>sr', function()
  require('telescope.builtin').resume()
end, { desc = '[S]earch [R]esume' })
vim.keymap.set('n', '<leader>s.', function()
  require('telescope.builtin').oldfiles()
end, { desc = '[S]earch Recent Files' })
vim.keymap.set('n', '<leader><leader>', function()
  require('telescope.builtin').find_files()
end, { desc = 'Find Files' })
vim.keymap.set('n', '<leader>/', function()
  require('telescope.builtin').current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
    winblend = 10,
    previewer = false,
  })
end, { desc = '[/] Fuzzily search in current buffer' })
vim.keymap.set('n', '<leader>s/', function()
  require('telescope.builtin').live_grep {
    grep_open_files = true,
    prompt_title = 'Live Grep in Open Files',
  }
end, { desc = '[S]earch [/] in Open Files' })
vim.keymap.set('n', '<leader>sn', function()
  require('telescope.builtin').find_files { cwd = vim.fn.stdpath 'config' }
end, { desc = '[S]earch [N]eovim files' })

-- [[ AI (CodeCompanion) ]]
vim.keymap.set({ 'n', 'v' }, '<leader>ac', '<cmd>CodeCompanionChat Toggle<cr>', { desc = '[A]I [C]hat' })
vim.keymap.set({ 'n', 'v' }, '<leader>aa', '<cmd>CodeCompanionActions<cr>', { desc = '[A]I [A]ctions' })
vim.keymap.set({ 'n', 'v' }, '<leader>as', utils.ai_switch_model, { desc = '[A]I [S]witch Model' })
vim.keymap.set('n', '<leader>aq', function()
  local line_num = vim.fn.line '.'
  utils.smart_chat('AI Question (Line ' .. line_num .. '): ', 'Regarding line ' .. line_num .. ': ', false)
end, { desc = '[A]I [Q]uestion (Buffer)' })
vim.keymap.set('v', '<leader>aq', function()
  utils.smart_chat('AI Question (Selection): ', nil, true)
end, { desc = '[A]I [Q]uestion (Selection)' })
vim.keymap.set({ 'n', 'v' }, '<leader>ar', function()
  local bufs = vim.api.nvim_list_bufs()
  for _, buf in ipairs(bufs) do
    if vim.api.nvim_buf_is_valid(buf) and vim.api.nvim_get_option_value('filetype', { buf = buf }) == 'codecompanion' then
      vim.api.nvim_buf_delete(buf, { force = true })
    end
  end
  vim.cmd 'CodeCompanionChat Add'
end, { desc = '[A]I [R]eset Chat' })
vim.keymap.set('n', '<leader>ae', function()
  utils.ai_edit(false)
end, { desc = '[A]I [E]dit (Buffer)' })
vim.keymap.set('v', '<leader>ae', function()
  utils.ai_edit(true)
end, { desc = '[A]I [E]dit (Selection)' })

-- [[ Git (Octo) ]]
vim.keymap.set('n', '<leader>op', '<cmd>Octo pr list<cr>', { desc = '[O]cto [P]R list' })
vim.keymap.set('n', '<leader>oi', '<cmd>Octo issue list<cr>', { desc = '[O]cto [I]ssue list' })
vim.keymap.set('n', '<leader>od', '<cmd>Octo discussion list<cr>', { desc = '[O]cto [D]iscussion list' })
vim.keymap.set('n', '<leader>on', '<cmd>Octo notification list<cr>', { desc = '[O]cto [N]otification list' })
vim.keymap.set('n', '<leader>os', '<cmd>Octo search<cr>', { desc = '[O]cto [S]earch' })
vim.keymap.set('n', '<leader>or', '<cmd>Octo repo list<cr>', { desc = '[O]cto [R]epo list' })
vim.keymap.set('n', '<leader>oa', '<cmd>Octo actions<cr>', { desc = '[O]cto [A]ctions' })

-- [[ Rust (Rustaceanvim) ]]
vim.keymap.set('n', '<leader>cr', '<cmd>RustLsp codeAction<cr>', { desc = 'Rust [C]ode [R]eaction (Action)' })
vim.keymap.set('n', '<leader>dr', '<cmd>RustLsp debuggables<cr>', { desc = 'Rust [D]ebug [R]unnables' })
vim.keymap.set('n', '<leader>rd', '<cmd>RustLsp debug<cr>', { desc = '[R]ust [D]ebug' })
