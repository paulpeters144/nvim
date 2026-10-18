-- debug.lua
--
-- Shows how to use the DAP plugin to debug your code.
--
-- Primarily focused on configuring the debugger for Go, but can
-- be extended to other languages as well. That's why it's called
-- kickstart.nvim and not kitchen-sink.nvim ;)

local function stop_debug()
  local dap = require 'dap'
  if vim.fn.has 'win32' == 1 then
    dap.disconnect { terminateDebuggee = true }
  else
    dap.terminate()
  end
  require('dapui').close()
end

return {
  -- NOTE: Yes, you can install new plugins here!
  'mfussenegger/nvim-dap',
  -- NOTE: And you can specify dependencies as well
  dependencies = {
    -- Creates a beautiful debugger UI
    'rcarriga/nvim-dap-ui',

    -- Required dependency for nvim-dap-ui
    'nvim-neotest/nvim-nio',

    -- Installs the debug adapters for you
    'mason-org/mason.nvim',
    'jay-babu/mason-nvim-dap.nvim',

  },
  keys = {
    -- Basic debugging keymaps, feel free to change to your liking!
    {
      '<leader>dc',
      function()
        require('dap').continue()
      end,
      desc = '[C]ontinue (F5)',
    },
    {
      '<leader>dt',
      stop_debug,
      desc = 'S[T]op/Terminate (F4)',
    },
    {
      '<leader>di',
      function()
        require('dap').step_into()
      end,
      desc = 'Step [I]nto (F1)',
    },
    {
      '<leader>do',
      function()
        require('dap').step_over()
      end,
      desc = 'Step [O]ver (F2)',
    },
    {
      '<leader>dO',
      function()
        require('dap').step_out()
      end,
      desc = 'Step [O]ut (F3)',
    },
    {
      '<leader>db',
      function()
        require('dap').toggle_breakpoint()
      end,
      desc = 'Toggle [B]reakpoint',
    },
    {
      '<leader>dB',
      function()
        require('dap').set_breakpoint(vim.fn.input 'Breakpoint condition: ')
      end,
      desc = 'Breakpoint (cond)',
    },
    -- Toggle to see last session result. Without this, you can't see session output in case of unhandled exception.
    {
      '<leader>du',
      function()
        require('dapui').toggle()
      end,
      desc = 'Toggle [U]I (F7)',
    },
    {
      '<leader>dh',
      function()
        require('dapui').eval()
      end,
      desc = '[H]over',
    },
    {
      '<leader>de',
      function()
        ---@diagnostic disable-next-line: missing-fields
        require('dapui').eval(nil, { enter = true, width = vim.o.columns })
      end,
      desc = '[E]val',
    },
    {
      '<F5>',
      function()
        require('dap').continue()
      end,
      desc = '[C]ontinue',
    },
    {
      '<F1>',
      function()
        require('dap').step_into()
      end,
      desc = 'Step [I]nto',
    },
    {
      '<F2>',
      function()
        require('dap').step_over()
      end,
      desc = 'Step [O]ver',
    },
    {
      '<F3>',
      function()
        require('dap').step_out()
      end,
      desc = 'Step [O]ut',
    },
    {
      '<F7>',
      function()
        require('dapui').toggle()
      end,
      desc = 'Toggle [U]I',
    },
    {
      '<F4>',
      stop_debug,
      desc = 'S[T]op/Terminate',
    },
    {
      '<F6>',
      function()
        require('dap').pause()
      end,
      desc = '[P]ause',
    },
    {
      '<F8>',
      function()
        require('dap').run_last()
      end,
      desc = 'Run [L]ast',
    },
    {
      '<F9>',
      function()
        require('dap').disconnect()
      end,
      desc = '[D]isconnect',
    },
    {
      '<F10>',
      function()
        require('dap').step_back()
      end,
      desc = 'Step [B]ack',
    },
  },
  config = function()
    local dap = require 'dap'
    local dapui = require 'dapui'

    require('mason-nvim-dap').setup {
      -- Makes a best effort to setup the various debuggers with
      -- reasonable debug configurations
      automatic_installation = true,

      -- You can provide additional configuration to the handlers,
      -- see mason-nvim-dap README for more information
      handlers = {
        function(config)
          require('mason-nvim-dap').default_setup(config)
        end,
        codelldb = function()
          -- rustaceanvim handles this
        end,
      },

      -- You'll need to check that you have the required things installed
      -- online, please don't ask me how to install them :)
      ensure_installed = {
        -- Update this to ensure that you have the debuggers for the langs you want
        'delve',
        'codelldb',
        -- NOTE: 'netcoredbg' is bundled with easy-dotnet-server, so it is no
        -- longer installed via Mason. C#/.NET debugging is handled entirely by
        -- easy-dotnet (see lua/plugins/easy-dotnet.lua).
      },
    }

    -- Dap UI setup
    -- For more information, see |:help nvim-dap-ui|
    ---@diagnostic disable-next-line: missing-fields
    dapui.setup {
      -- Set icons to characters that are more likely to work in every terminal.
      --    Feel free to remove or use ones that you like more! :)
      --    Don't feel like these are good choices.
      icons = { expanded = '▾', collapsed = '▸', current_frame = '*' },
      ---@diagnostic disable-next-line: missing-fields
      controls = {
        icons = {
          pause = '⏸ F6',
          play = '▶ F5',
          step_into = '⏎ F1',
          step_over = '⏭ F2',
          step_out = '⏮ F3',
          step_back = 'b F10',
          run_last = '▶▶ F8',
          terminate = '⏹ F4',
          disconnect = '⏏ F9',
        },
      },
      floating = {
        max_height = 0.9,
        max_width = 0.9, -- 90% of screen width
        border = 'rounded',
        mappings = {
          close = { 'q', '<Esc>' },
        },
      },
    }

    -- Change breakpoint icons
    vim.api.nvim_set_hl(0, 'DapBreak', { fg = '#e51400' })
    vim.api.nvim_set_hl(0, 'DapStop', { fg = '#ffcc00' })
    local breakpoint_icons = vim.g.have_nerd_font
        and { Breakpoint = '', BreakpointCondition = '', BreakpointRejected = '', LogPoint = '', Stopped = '' }
      or { Breakpoint = '●', BreakpointCondition = '⊜', BreakpointRejected = '⊘', LogPoint = '◆', Stopped = '⭔' }
    for type, icon in pairs(breakpoint_icons) do
      local tp = 'Dap' .. type
      local hl = (type == 'Stopped') and 'DapStop' or 'DapBreak'
      vim.fn.sign_define(tp, { text = icon, texthl = hl, numhl = hl })
    end

    dap.listeners.after.event_initialized['dapui_config'] = dapui.open
    dap.listeners.before.event_terminated['dapui_config'] = dapui.close
    dap.listeners.before.event_exited['dapui_config'] = dapui.close

    -- NOTE: C#/.NET debugging is handled entirely by easy-dotnet-server, which
    -- bundles netcoredbg and auto-registers its own DAP configuration via
    -- `debugger.auto_register_dap`. Any manual `dap.adapters.coreclr` or
    -- `dap.configurations.cs` here would conflict with it, so they are removed.
    -- Use `:Dotnet debug` / `<leader>lnd` instead of dap's run_last for C#.
  end,
}
