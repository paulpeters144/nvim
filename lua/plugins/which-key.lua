return {
  { -- Useful plugin to show you pending keybinds.
    'folke/which-key.nvim',
    event = 'VimEnter', -- Sets the loading event to 'VimEnter'
    opts = {
      delay = 0,
      icons = {
        mappings = vim.g.have_nerd_font,
        keys = vim.g.have_nerd_font and {} or {
          Up = '<Up> ',
          Down = '<Down> ',
          Left = '<Left> ',
          Right = '<Right> ',
          C = '<C-…> ',
          M = '<M-…> ',
          D = '<D-…> ',
          S = '<S-…> ',
          CR = '<CR> ',
          Esc = '<Esc> ',
          ScrollWheelDown = '<ScrollWheelDown> ',
          ScrollWheelUp = '<ScrollWheelUp> ',
          NL = '<NL> ',
          BS = '<BS> ',
          Space = '<Space> ',
          Tab = '<Tab> ',
          F1 = '<F1>',
          F2 = '<F2>',
          F3 = '<F3>',
          F4 = '<F4>',
          F5 = '<F5>',
          F6 = '<F6>',
          F7 = '<F7>',
          F8 = '<F8>',
          F9 = '<F9>',
          F10 = '<F10>',
          F11 = '<F11>',
          F12 = '<F12>',
        },
      },

      -- Documented options for better UI
      preset = 'modern',
      win = {
        border = 'rounded',
        padding = { 1, 2 }, -- [top, right, bottom, left]
        title = ' Shortcuts ',
        title_pos = 'center',
        zindex = 1000,
        wo = {
          winblend = 10, -- Slight transparency
        },
      },
      layout = {
        width = { min = 20, max = 50 },
        spacing = 3,
        align = 'left',
      },
      plugins = {
        marks = true, -- shows a list of your marks on ' and `
        registers = true, -- shows your registers on " in NORMAL or <C-r> in INSERT mode
        spelling = {
          enabled = true, -- enabling this will show WhichKey when pressing z= to select spelling suggestions
          suggestions = 20, -- how many suggestions should be shown in the list?
        },
      },

      spec = {
        { '<leader>a', group = 'AI', icon = '🤖' },
        { '<leader>c', group = 'Code', icon = '📝' },
        { '<leader>s', group = 'Search', icon = '🔍' },
        { '<leader>t', group = 'Toggle', icon = '🔧' },
        { '<leader>h', group = 'Git Hunk', mode = { 'n', 'v' }, icon = '⚓' },
        { '<leader>g', group = 'Git', icon = '🏷️' },
        { '<leader>b', group = 'Buffer', icon = '📖' },
        { '<leader>w', group = 'Window', icon = '🪟' },
        { '<leader>q', group = 'Session', icon = '💾' },
        { '<leader>o', group = 'Octo', icon = '🐙' },
      },
    },
  },
}
