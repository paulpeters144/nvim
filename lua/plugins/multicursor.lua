return {
  {
    'jake-stewart/multicursor.nvim',
    branch = '1.0',
    config = function()
      local mc = require 'multicursor-nvim'

      mc.setup()

      local set = vim.keymap.set

      -- Add or skip cursor above/below the main cursor.
      set({ 'n', 'x' }, '<up>', function()
        mc.lineAddCursor(-1)
      end, { desc = 'Add cursor ↑' })
      set({ 'n', 'x' }, '<down>', function()
        mc.lineAddCursor(1)
      end, { desc = 'Add cursor ↓' })
      set({ 'n', 'x' }, '<leader>m<up>', function()
        mc.lineSkipCursor(-1)
      end, { desc = 'Skip cursor ↑' })
      set({ 'n', 'x' }, '<leader>m<down>', function()
        mc.lineSkipCursor(1)
      end, { desc = 'Skip cursor ↓' })

      -- Add and remove cursors with control + left click.
      set('n', '<c-leftmouse>', mc.handleMouse)
      set('n', '<c-leftdrag>', mc.handleMouseDrag)
      set('n', '<c-leftrelease>', mc.handleMouseRelease)

      -- Match word/selection
      set({ 'n', 'x' }, '<leader>mn', function()
        mc.matchAddCursor(1)
      end, { desc = 'Add [N]ext match' })
      set({ 'n', 'x' }, '<leader>ms', function()
        mc.matchSkipCursor(1)
      end, { desc = '[S]kip next match' })
      set({ 'n', 'x' }, '<leader>mN', function()
        mc.matchAddCursor(-1)
      end, { desc = 'Add [P]rev match' })
      set({ 'n', 'x' }, '<leader>mS', function()
        mc.matchSkipCursor(-1)
      end, { desc = 'Skip prev match' })

      -- Match all
      set({ 'n', 'x' }, '<leader>ma', function()
        mc.matchAllAddCursors()
      end, { desc = 'Add [A]ll matches' })

      -- Actions
      set({ 'n', 'x' }, '<leader>ml', function()
        mc.alignCursors()
      end, { desc = 'A[l]ign cursors' })
      set('n', '<leader>mr', mc.restoreCursors, { desc = '[R]estore cursors' })

      -- Disable and enable cursors.
      set({ 'n', 'x' }, '<c-q>', mc.toggleCursor, { desc = 'Toggle multicursor' })

      -- Mappings defined in a keymap layer only apply when there are
      -- multiple cursors. This lets you have overlapping mappings.
      mc.addKeymapLayer(function(layerSet)
        -- Select a different cursor as the main one.
        layerSet({ 'n', 'x' }, '<left>', mc.prevCursor)
        layerSet({ 'n', 'x' }, '<right>', mc.nextCursor)

        -- Delete the main cursor.
        layerSet({ 'n', 'x' }, '<leader>mx', mc.deleteCursor, { desc = 'Delete cursor' })

        -- Enable and clear cursors using escape.
        layerSet('n', '<esc>', function()
          if not mc.cursorsEnabled() then
            mc.enableCursors()
          else
            mc.clearCursors()
          end
        end)
      end)

      -- Customize how cursors look.
      local hl = vim.api.nvim_set_hl
      hl(0, 'MultiCursorCursor', { reverse = true })
      hl(0, 'MultiCursorVisual', { link = 'Visual' })
      hl(0, 'MultiCursorSign', { link = 'SignColumn' })
      hl(0, 'MultiCursorMatchPreview', { link = 'Search' })
      hl(0, 'MultiCursorDisabledCursor', { reverse = true })
      hl(0, 'MultiCursorDisabledVisual', { link = 'Visual' })
      hl(0, 'MultiCursorDisabledSign', { link = 'SignColumn' })
    end,
  },
}
