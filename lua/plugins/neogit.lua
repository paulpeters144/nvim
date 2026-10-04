return {
  {
    'NeogitOrg/neogit',
    dependencies = {
      'nvim-lua/plenary.nvim', -- required
      'nvim-telescope/telescope.nvim', -- optional
    },
    config = function()
      require('neogit').setup {
        integrations = {
          diffview = true,
          telescope = true,
        },
      }
    end,
    keys = {
      { '<leader>gg', '<cmd>Neogit<cr>', desc = 'Neogit (Full UI)' },
      {
        '<leader>gs',
        function()
          local git_root = vim.trim(vim.fn.system 'git rev-parse --show-toplevel')
          local make_entry = require 'telescope.make_entry'
          local entry_display = require 'telescope.pickers.entry_display'

          local displayer = entry_display.create {
            separator = '',
            items = {
              { width = 2 },
              { width = 2 },
              { remaining = true },
            },
          }

          local icons = {
            ['A'] = { icon = '+', hl = 'TelescopeResultsDiffAdd' },
            ['M'] = { icon = '~', hl = 'TelescopeResultsDiffChange' },
            ['D'] = { icon = '-', hl = 'TelescopeResultsDiffDelete' },
            ['?'] = { icon = '?', hl = 'TelescopeResultsDiffUntracked' },
            ['R'] = { icon = '', hl = 'TelescopeResultsDiffChange' },
            ['U'] = { icon = '‡', hl = 'TelescopeResultsDiffAdd' },
          }

          require('telescope.builtin').git_status {
            entry_maker = function(line)
              if line == '' then
                return nil
              end
              local mod, file = line:match '^(..) (.+)$'
              if not mod then
                return nil
              end

              local display_path = file
              if git_root ~= '' then
                local idx = file:find(vim.fs.normalize(git_root), 1, true)
                if idx then
                  display_path = file:sub(idx + #git_root):gsub('^[\\/]+', '')
                end
              end

              return make_entry.set_default_entry_mt({
                value = file,
                status = mod,
                ordinal = line,
                path = (function()
                  local is_windows = vim.uv.os_uname().sysname == 'Windows_NT'
                  return git_root .. (is_windows and '\\' or '/') .. file
                end)(),
                display = function(entry)
                  local x = string.sub(entry.status, 1, 1)
                  local y = string.sub(entry.status, -1)
                  local sx = icons[x] or {}
                  local sy = icons[y] or {}
                  return displayer {
                    { sx.icon or ' ', sx.hl },
                    { sy.icon or ' ', sy.hl },
                    { display_path },
                  }
                end,
              }, {})
            end,
          }
        end,
        desc = 'Git [S]tatus (Telescope)',
      },
    },
  },
}
