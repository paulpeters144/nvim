local utils = require 'custom.utils'

-- [[ Basic Keymaps ]]
vim.keymap.set('n', '<Esc>', utils.clear_ui, { desc = 'Clear search highlights and floating windows' })
vim.keymap.set('n', '-', '<cmd>Oil<cr>', { desc = 'Open parent (Oil)' })
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
vim.keymap.set('n', '<leader>tD', function()
  local enabled = not vim.diagnostic.is_enabled()
  vim.diagnostic.enable(enabled)
  vim.notify(enabled and 'Diagnostics: ON' or 'Diagnostics: OFF', vim.log.levels.INFO)
end, { desc = 'Toggle [D]iagnostics' })

-- [[ Movement & Visual ]]
vim.keymap.set('n', '<C-d>', '<C-d>zz', { desc = 'Scroll down and center' })
vim.keymap.set('n', '<C-u>', '<C-u>zz', { desc = 'Scroll up and center' })
vim.keymap.set('n', '<C-f>', '<C-f>zz', { desc = 'Page down and center' })
vim.keymap.set('n', '<C-b>', '<C-b>zz', { desc = 'Page up and center' })
vim.keymap.set('n', '<C-b>', '<C-v>', { desc = '[V]isual block mode (overrides PgUp)' })

-- [[ Window Navigation ]]
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- [[ Window Management ]]
vim.keymap.set('n', '<leader>wr', '<C-w>=', { desc = '[R]e-equalize' })
vim.keymap.set('n', '<leader>wv', '<C-w>v', { desc = '[V]ertical split' })
vim.keymap.set('n', '<leader>wh', '<C-w>s', { desc = '[H]orizontal split' })
vim.keymap.set('n', '<leader>wd', '<C-w>c<C-w>=', { desc = '[D]elete' })

-- [[ Buffer Management ]]
vim.keymap.set('n', '<leader>bn', '<cmd>bnext<cr>', { desc = '[N]ext' })
vim.keymap.set('n', '<leader>bp', '<cmd>bprevious<cr>', { desc = '[P]revious' })
vim.keymap.set('n', '<leader>bl', '<cmd>b#<cr>', { desc = '[L]ast' })
vim.keymap.set('n', '<leader>bd', utils.smart_buf_delete, { desc = '[D]elete' })
vim.keymap.set('n', '<leader>bq', '<cmd>bufdo bdelete<cr>', { desc = '[Q]uit others' })
vim.keymap.set('n', '<leader>by', utils.copy_relative_path, { desc = 'cop[Y] relative path' })
vim.keymap.set('n', '<leader>bY', utils.copy_absolute_path, { desc = 'cop[Y] absolute path' })
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
end, { desc = 'Load (current dir)' })
vim.keymap.set('n', '<leader>qS', function()
  require('persistence').select()
end, { desc = '[S]elect from list' })
vim.keymap.set('n', '<leader>ql', function()
  require('persistence').load { last = true }
end, { desc = '[L]ast session' })
vim.keymap.set('n', '<leader>qd', function()
  require('persistence').stop()
end, { desc = '[D]elete session' })

-- [[ Search (Telescope) ]]
vim.keymap.set('n', '<leader>sh', function()
  require('telescope.builtin').help_tags()
end, { desc = '[S]earch [H]elp tags' })
vim.keymap.set('n', '<leader>sk', function()
  require('telescope.builtin').keymaps()
end, { desc = '[S]earch [K]eymaps' })
vim.keymap.set('n', '<leader>ss', function()
  require('telescope.builtin').builtin()
end, { desc = '[S]earch built-in [S]electors' })
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
end, { desc = 'Find Files (Telescope)' })
vim.keymap.set('n', '<leader>/', function()
  require('telescope.builtin').current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
    winblend = 10,
    previewer = false,
  })
end, { desc = 'Search in Buffer (fuzzy)' })
vim.keymap.set('n', '<leader>s/', function()
  require('telescope.builtin').live_grep {
    grep_open_files = true,
    prompt_title = 'Live Grep in Open Files',
  }
end, { desc = '[S]earch [/] in Open Files' })
vim.keymap.set('n', '<leader>sn', function()
  require('telescope.builtin').find_files { cwd = vim.fn.stdpath 'config' }
end, { desc = '[S]earch [N]eovim files' })
vim.keymap.set('n', '<leader>sH', function()
  require('telescope.builtin').find_files {
    prompt_title = 'Find Files (incl. hidden)',
    find_command = { 'rg', '--files', '--hidden' },
  }
end, { desc = '[S]earch [H]idden files' })

-- [[ Git (Octo) ]]
vim.keymap.set('n', '<leader>op', '<cmd>Octo pr list<cr>', { desc = '[P]R List' })
vim.keymap.set('n', '<leader>oi', '<cmd>Octo issue list<cr>', { desc = '[I]ssue List' })
vim.keymap.set('n', '<leader>od', '<cmd>Octo discussion list<cr>', { desc = '[D]iscussion List' })
vim.keymap.set('n', '<leader>on', '<cmd>Octo notification list<cr>', { desc = '[N]otification List' })
vim.keymap.set('n', '<leader>os', '<cmd>Octo search<cr>', { desc = '[S]earch' })
vim.keymap.set('n', '<leader>or', '<cmd>Octo repo list<cr>', { desc = '[R]epo List' })
vim.keymap.set('n', '<leader>oa', '<cmd>Octo actions<cr>', { desc = '[A]ctions' })

-- [[ Rust (Rustaceanvim) ]]
vim.keymap.set('n', '<leader>lra', '<cmd>RustLsp codeAction<cr>', { desc = 'Code [A]ction' })
vim.keymap.set('n', '<leader>lrg', '<cmd>RustLsp debuggables<cr>', { desc = 'Debu[g]gables' })
vim.keymap.set('n', '<leader>lrd', '<cmd>RustLsp debug<cr>', { desc = '[D]ebug' })
vim.keymap.set('n', '<leader>lrr', function()
  for _, client in ipairs(vim.lsp.get_clients { name = 'rust-analyzer' }) do
    client:stop()
  end
  vim.defer_fn(function()
    vim.cmd 'silent! edit %'
    vim.notify('Rust LSP restarted', vim.log.levels.INFO)
  end, 500)
end, { desc = '[R]estart LSP' })

vim.keymap.set('n', '<leader>lrc', function()
  for _, client in ipairs(vim.lsp.get_clients { name = 'rust-analyzer' }) do
    local settings = vim.deepcopy(client.settings or {})
    local ra = settings['rust-analyzer'] or {}
    local check = ra.check or {}
    local command = check.command or 'check'
    if command == 'clippy' then
      check.command = 'check'
      ra.check = check
      settings['rust-analyzer'] = ra
      client.settings = settings
      vim.notify('Clippy: OFF (using cargo check)', vim.log.levels.INFO)
    else
      check.command = 'clippy'
      ra.check = check
      settings['rust-analyzer'] = ra
      client.settings = settings
      vim.notify('Clippy: ON', vim.log.levels.INFO)
    end
    client:notify('workspace/didChangeConfiguration', { settings = settings })
  end
end, { desc = 'Toggle [C]lippy' })
