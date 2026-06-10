-- Adds git related signs to the gutter, as well as utilities for managing changes
-- NOTE: gitsigns is already included in init.lua but contains only the base
-- config. This will add also the recommended keymaps.

return {
  {
    'lewis6991/gitsigns.nvim',
    opts = {
      signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
      },
      on_attach = function(bufnr)
        local gitsigns = require 'gitsigns'

        local function map(mode, l, r, opts)
          opts = opts or {}
          opts.buffer = bufnr
          vim.keymap.set(mode, l, r, opts)
        end

        -- Navigation
        map('n', ']h', function()
          if vim.wo.diff then
            vim.cmd.normal { ']h', bang = true }
          else
            gitsigns.nav_hunk 'next'
          end
        end, { desc = 'Next [H]unk' })

        map('n', '[h', function()
          if vim.wo.diff then
            vim.cmd.normal { '[h', bang = true }
          else
            gitsigns.nav_hunk 'prev'
          end
        end, { desc = 'Prev [H]unk' })

        -- Actions
        -- visual mode
        map('v', '<leader>hs', function()
          gitsigns.stage_hunk { vim.fn.line '.', vim.fn.line 'v' }
        end, { desc = 'Stage [H]unk' })
        map('v', '<leader>hr', function()
          gitsigns.reset_hunk { vim.fn.line '.', vim.fn.line 'v' }
        end, { desc = 'Reset [H]unk' })
        -- normal mode
        map('n', '<leader>hs', gitsigns.stage_hunk, { desc = 'Stage [H]unk' })
        map('n', '<leader>hr', gitsigns.reset_hunk, { desc = 'Reset [H]unk' })
        map('n', '<leader>hS', gitsigns.stage_buffer, { desc = '[S]tage Buffer' })
        map('n', '<leader>hu', gitsigns.undo_stage_hunk, { desc = '[U]ndo Stage Hunk' })
        map('n', '<leader>hR', gitsigns.reset_buffer, { desc = '[R]eset Buffer' })
        map('n', '<leader>hp', gitsigns.preview_hunk, { desc = '[P]review Hunk' })
        map('n', '<leader>hb', function()
          gitsigns.blame_line { full = true }
        end, { desc = '[B]lame Line' })
        map('n', '<leader>hd', gitsigns.diffthis, { desc = '[D]iff (Index)' })
        map('n', '<leader>hD', function()
          gitsigns.diffthis '~'
        end, { desc = '[D]iff (Last Commit)' })

        -- Toggles
        map('n', '<leader>tb', gitsigns.toggle_current_line_blame, { desc = 'Toggle [B]lame' })
        map('n', '<leader>td', gitsigns.toggle_deleted, { desc = 'Toggle [D]eleted' })
      end,
    },
  },
}
