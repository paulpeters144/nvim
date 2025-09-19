vim.keymap.set('n', '-', '<CMD>Oil<CR>', { desc = 'Open parent directory' })

vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

vim.keymap.set('n', '<leader>bn', ':bnext<CR>', { desc = '[B]uffer [N]ext' })
vim.keymap.set('n', '<leader>bp', ':bprevious<CR>', { desc = '[B]uffer [P]revious' })
vim.keymap.set('n', '<leader>bl', ':b#<CR>', { desc = '[B]uffer [L]ast' }) -- Close the current buffer
vim.keymap.set('n', '<leader>bc', ':bdelete<CR>', { desc = '[B]uffer [C]lose' })
vim.keymap.set('n', '<leader>bq', ':bufdo bdelete<CR>', { desc = '[B]uffer [Q]uit all others' })

vim.keymap.set('n', '<C-b>', '<C-v>', { desc = 'Visual block mode' })

vim.keymap.set('n', '<C-d>', '<C-d>zz')
vim.keymap.set('n', '<C-u>', '<C-u>zz')
vim.keymap.set('n', '<C-f>', '<C-f>zz')
vim.keymap.set('n', '<C-b>', '<C-b>zz')
vim.keymap.set('n', 'Y', 'yy')

vim.keymap.set('n', '<leader>qs', function()
  require('persistence').load()
end, { desc = 'Save session' })
vim.keymap.set('n', '<leader>qS', function()
  require('persistence').select()
end, { desc = 'Select recent session' })
vim.keymap.set('n', '<leader>ql', function()
  require('persistence').load { last = true }
end, { desc = 'Load last session' })
vim.keymap.set('n', '<leader>qd', function()
  require('persistence').stop()
end, { desc = 'Delete session' })

-- vim.keymap.del("n", "<leader>e")
-- vim.keymap.del("n", "<leader>E")

-- -- Leaving this here as an example in case you want to delete default keymaps
-- -- delete default buffer navigation keymaps
-- vim.keymap.del('n', '<S-h>')
-- vim.keymap.del('n', '<S-l>')

-- vim.keymap.set("n", "<S-h>", function()
--   require("telescope.builtin").buffers(require("telescope.themes").get_ivy({
--     sort_mru = true,
--     -- -- Sorts current and last buffer to the top and selects the lastused (default: false)
--     -- -- Leave this at false, otherwise when put in normal mode, the buffer
--     -- -- below is selected, not the one at the top
--     sort_lastused = false,
--     initial_mode = "normal",
--     -- Pre-select the current buffer
--     -- ignore_current_buffer = false,
--     -- select_current = true,
--     layout_config = {
--       -- Set preview width, 0.7 sets it to 70% of the window width
--       preview_width = 0.45,
--     },
--   }))
-- end, { desc = "[P]Open telescope buffers" })

vim.keymap.set('n', '<S-h>', function()
  require('telescope.builtin').buffers(require('telescope.themes').get_ivy {
    sort_mru = true,
    sort_lastused = false,
    initial_mode = 'normal',
    layout_config = {
      height = 45, -- number of lines tall (you can also try 0.5 for 50% of screen)
      preview_width = 0.45,
    },
    attach_mappings = function(_, map)
      local actions = require 'telescope.actions'

      -- Map `d` in normal mode inside telescope
      map('n', 'd', actions.delete_buffer)

      return true
    end,
  })
end, { desc = '[P]Open telescope buffers' })
