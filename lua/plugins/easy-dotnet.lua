-- easy-dotnet.nvim configuration
-- Plugin: https://github.com/GustavEikaas/easy-dotnet.nvim
--
-- NOTE: easy-dotnet now does most of its work in a companion C# server
-- (the `EasyDotnet` global dotnet tool). Keep it up to date with:
--   :Dotnet _server update
-- or:
--   dotnet tool update -g EasyDotnet
--
-- Requirements:
--   * Neovim 0.11+ (built with LuaJIT)
--   * dotnet tool install -g EasyDotnet
--   * a picker: telescope.nvim (installed), fzf-lua, or snacks.nvim

-- Keymaps (all under <leader>ln, leader = <space>):
--
--   Run:      r  run default | R  run (pick) | rp  run + launch profile
--   Debug:    d  debug default | D  debug (pick) | dp  debug + launch profile
--   Test:     t  test runner | tt  test (pick) | ts  test solution
--   Build:    b  build (pick) | B  build solution | bq  build + quickfix
--             bc  clean | br  restore
--   Watch:    w  watch default | W  watch (pick)
--   Solution: s  select | sa  add project | sr  remove project
--   Package:  p  add package | P  remove package | o  outdated packages
--   New:      n  new template
--   Secrets:  S  user secrets
--   Diag:     x  workspace | xe  errors | xw  warnings
--   EF:       e  db update | eD  db update (pick) | el  migrations list
--             em  migrations add | eR  migrations remove
--   Terminal: T  managed terminal toggle
--   Server:   u  update | h  restart | i  checkhealth | X  reset

local function add_dotnet_mappings()
  local dotnet = require 'easy-dotnet'

  local function map(lhs, cmd, desc)
    vim.keymap.set('n', lhs, function()
      vim.cmd(cmd)
    end, { desc = desc, nowait = true })
  end

  vim.api.nvim_create_user_command('Secrets', function()
    dotnet.secrets()
  end, {})

  -- Run
  map('<leader>lnr', 'Dotnet run default', 'Run default')
  map('<leader>lnR', 'Dotnet run', 'Run (pick)')
  map('<leader>lnrp', 'Dotnet run profile default', 'Run + launch profile')

  -- Debug
  map('<leader>lnd', 'Dotnet debug default', 'Debug default')
  map('<leader>lnD', 'Dotnet debug', 'Debug (pick)')
  map('<leader>lndp', 'Dotnet debug profile default', 'Debug + launch profile')

  -- Test
  map('<leader>lnt', 'Dotnet testrunner', 'Test runner')
  map('<leader>lntt', 'Dotnet test', 'Test (pick)')
  map('<leader>lnts', 'Dotnet test solution', 'Test solution')

  -- Build / clean / restore
  map('<leader>lnb', 'Dotnet build', 'Build (pick)')
  map('<leader>lnB', 'Dotnet build solution', 'Build solution')
  map('<leader>lnbq', 'Dotnet build quickfix', 'Build + quickfix')
  map('<leader>lnbc', 'Dotnet clean', 'Clean')
  map('<leader>lnbr', 'Dotnet restore', 'Restore')

  -- Watch
  map('<leader>lnw', 'Dotnet watch default', 'Watch default')
  map('<leader>lnW', 'Dotnet watch', 'Watch (pick)')

  -- Solution
  map('<leader>lns', 'Dotnet solution select', 'Solution select')
  map('<leader>lnsa', 'Dotnet solution add', 'Solution add')
  map('<leader>lnsr', 'Dotnet solution remove', 'Solution remove')

  -- Packages
  map('<leader>lnp', 'Dotnet add package', 'Add package')
  map('<leader>lnP', 'Dotnet remove package', 'Remove package')
  map('<leader>lno', 'Dotnet outdated', 'Outdated packages')

  -- New template
  map('<leader>lnn', 'Dotnet new', 'New template')

  -- User secrets
  map('<leader>lnS', 'Secrets', 'User secrets')

  -- Workspace diagnostics
  map('<leader>lnx', 'Dotnet diagnostic', 'Workspace diagnostics')
  map('<leader>lnxe', 'Dotnet diagnostic errors', 'Diagnostics: errors')
  map('<leader>lnxw', 'Dotnet diagnostic warnings', 'Diagnostics: warnings')

  -- Entity Framework (requires dotnet-ef tool)
  map('<leader>lne', 'Dotnet ef database update', 'EF database update')
  map('<leader>lneD', 'Dotnet ef database update pick', 'EF database update (pick)')
  map('<leader>lnel', 'Dotnet ef migrations list', 'EF migrations list')
  map('<leader>lneR', 'Dotnet ef migrations remove', 'EF migrations remove')
  vim.keymap.set('n', '<leader>lnem', function()
    vim.ui.input({ prompt = 'Migration name: ' }, function(name)
      if name and name ~= '' then
        vim.cmd('Dotnet ef migrations add ' .. name)
      end
    end)
  end, { desc = 'EF migrations add', nowait = true })

  -- Managed terminal
  map('<leader>lnT', 'Dotnet terminal toggle', 'Managed terminal toggle')

  -- Server / utility
  map('<leader>lnu', 'Dotnet _server update', 'Server update')
  map('<leader>lnh', 'Dotnet _server restart', 'Server restart')
  map('<leader>lni', 'checkhealth easy-dotnet', 'Checkhealth')
  vim.keymap.set('n', '<leader>lnX', function()
    dotnet.reset()
  end, { desc = 'Reset plugin', nowait = true })

  -- Roslyn language server (the process that produces C# diagnostics/hover/rename).
  -- Restart it to clear stale diagnostics after a manual namespace/file rename.
  vim.keymap.set('n', '<leader>lnl', function()
    vim.cmd 'lsp restart easy_dotnet'
    vim.notify('C# Roslyn LSP restarted', vim.log.levels.INFO)
  end, { desc = 'Restart Roslyn LSP', nowait = true })
end

return {
  'GustavEikaas/easy-dotnet.nvim',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-telescope/telescope.nvim',
    'mfussenegger/nvim-dap', -- used by the built-in debugger
  },
  config = function()
    local dotnet = require 'easy-dotnet'

    dotnet.setup {
      -- Picker used for solution/project/test selection.
      -- Leave nil to auto-detect (snacks -> fzf -> telescope -> basic).
      picker = 'telescope',

      server = {
        -- Set true for .NET Framework support on Windows (requires Visual Studio + nuget CLI)
        use_visual_studio = false,
        ---@type nil | "Off" | "Critical" | "Error" | "Warning" | "Information" | "Verbose" | "All"
        log_level = nil, -- avoid "Verbose" unless debugging the plugin itself
      },

      test_runner = {
        ---@type "split" | "vsplit" | "float" | "buf"
        viewmode = 'float',
        -- `noBuild` and `enable_buffer_test_execution` were removed in
        -- Test Runner v2: buffer test execution is always enabled now.
      },

      projx_lsp = {
        enabled = true, -- package autocomplete in .csproj (enabled by default)
      },

      debugger = {
        -- netcoredbg is bundled with the EasyDotnet server, so bin_path is
        -- optional. Only set bin_path to override with your own adapter.
        engine = 'netcoredbg', -- "netcoredbg" | "dncdbg" | "sharpdbg"
        console = 'integratedTerminal', -- or "externalTerminal" for a detached OS window
      },

      -- `notifications.handler` defaults to a spinner that reports job results
      -- (e.g. "Server restarted" after `:Dotnet _server restart`). Leaving it
      -- default keeps that success feedback visible. Only set it to `false` if
      -- you use lualine's dotnet components and want to avoid double logging.

      auto_bootstrap_namespace = {
        type = 'file_scoped', -- "file_scoped" | "block_scoped"
        enabled = true,
      },

      -- NOTE: the old `terminal = function(...)` callback was removed.
      -- Run/build/test/watch/restore now use the built-in managed terminal.
      -- Customize it via `managed_terminal` (e.g. { auto_hide = true }), or
      -- use `external_terminal` to spawn an OS window instead.
    }

    add_dotnet_mappings()
  end,
}
