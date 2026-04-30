-- debug.lua
--
-- Shows how to use the DAP plugin to debug your code.
--
-- Primarily focused on configuring the debugger for Go, but can
-- be extended to other languages as well. That's why it's called
-- kickstart.nvim and not kitchen-sink.nvim ;)

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

    -- Add your own debuggers here
    'leoluz/nvim-dap-go',
  },
  keys = {
    -- Basic debugging keymaps, feel free to change to your liking!
    {
      '<leader>dc',
      function()
        require('dap').continue()
      end,
      desc = 'Debug: Start/Continue (F5)',
    },
    {
      '<leader>di',
      function()
        require('dap').step_into()
      end,
      desc = 'Debug: Step Into (F1)',
    },
    {
      '<leader>do',
      function()
        require('dap').step_over()
      end,
      desc = 'Debug: Step Over (F2)',
    },
    {
      '<leader>dO',
      function()
        require('dap').step_out()
      end,
      desc = 'Debug: Step Out (F3)',
    },
    {
      '<leader>db',
      function()
        require('dap').toggle_breakpoint()
      end,
      desc = 'Debug: Toggle Breakpoint',
    },
    {
      '<leader>dB',
      function()
        require('dap').set_breakpoint(vim.fn.input 'Breakpoint condition: ')
      end,
      desc = 'Debug: Set Breakpoint',
    },
    -- Toggle to see last session result. Without this, you can't see session output in case of unhandled exception.
    {
      '<leader>du',
      function()
        require('dapui').toggle()
      end,
      desc = 'Debug: Toggle UI (F7)',
    },
    {
      '<leader>dh',
      function()
        require('dapui').eval()
      end,
      desc = 'Debug: Hover',
    },
    {
      '<leader>de',
      function()
        require('dapui').eval(nil, { enter = true, width = vim.o.columns })
      end,
      desc = 'Debug: Eval',
    },
    {
      '<F5>',
      function()
        require('dap').continue()
      end,
      desc = 'Debug: Start/Continue',
    },
    {
      '<F1>',
      function()
        require('dap').step_into()
      end,
      desc = 'Debug: Step Into',
    },
    {
      '<F2>',
      function()
        require('dap').step_over()
      end,
      desc = 'Debug: Step Over',
    },
    {
      '<F3>',
      function()
        require('dap').step_out()
      end,
      desc = 'Debug: Step Out',
    },
    {
      '<F7>',
      function()
        require('dapui').toggle()
      end,
      desc = 'Debug: See last session result.',
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
        'netcoredbg',
      },
    }

    -- Dap UI setup
    -- For more information, see |:help nvim-dap-ui|
    dapui.setup {
      -- Set icons to characters that are more likely to work in every terminal.
      --    Feel free to remove or use ones that you like more! :)
      --    Don't feel like these are good choices.
      icons = { expanded = '▾', collapsed = '▸', current_frame = '*' },
      controls = {
        icons = {
          pause = '⏸',
          play = '▶ F5',
          step_into = '⏎ F1',
          step_over = '⏭ F2',
          step_out = '⏮ F3',
          step_back = 'b',
          run_last = '▶▶',
          terminate = '⏹',
          disconnect = '⏏',
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

    -- Install golang specific config
    require('dap-go').setup {
      delve = {
        -- On Windows delve must be run attached or it crashes.
        -- See https://github.com/leoluz/nvim-dap-go/blob/main/README.md#configuring
        detached = vim.fn.has 'win32' == 0,
      },
    }

    dap.adapters.coreclr = {
      type = 'executable',
      command = function()
        local mason_registry = require 'mason-registry'
        if mason_registry.is_installed 'netcoredbg' then
          local pkg = mason_registry.get_package 'netcoredbg'
          local path = pkg:get_install_path() .. '/netcoredbg/netcoredbg.exe'
          if vim.fn.executable(path) == 1 then
            return path
          end
        end
        -- Fallback if mason isn't used or package structure changes
        return 'netcoredbg'
      end,
      args = { '--interpreter=vscode' },
    }

    local last_project_dir = nil
    dap.configurations.cs = {
      {
        type = 'coreclr',
        name = 'Launch Project (Select)',
        request = 'launch',
        program = function()
          return coroutine.create(function(dap_run_co)
            local projects = vim.fn.globpath(vim.fn.getcwd(), '**/*.csproj', 0, 1)
            if #projects == 0 then
              vim.ui.input({ prompt = 'Path to DLL', default = vim.fn.getcwd() .. '/bin/Debug/', completion = 'file' }, function(input)
                coroutine.resume(dap_run_co, input)
              end)
              return
            end

            vim.ui.select(projects, {
              prompt = 'Select project to debug:',
              format_item = function(item)
                return vim.fn.fnamemodify(item, ':t')
              end,
            }, function(project_path)
              if not project_path then
                coroutine.resume(dap_run_co, nil)
                return
              end
              local project_dir = vim.fn.fnamemodify(project_path, ':h')
              local project_name = vim.fn.fnamemodify(project_path, ':t:r')
              last_project_dir = project_dir

              local dlls = vim.fn.globpath(project_dir, 'bin/Debug/**/*.dll', 0, 1)
              local matches = {}
              for _, dll in ipairs(dlls) do
                if vim.fn.fnamemodify(dll, ':t:r') == project_name then
                  table.insert(matches, dll)
                end
              end

              if #matches == 0 then
                vim.ui.input({ prompt = 'Path to DLL', default = project_dir .. '/bin/Debug/', completion = 'file' }, function(input)
                  coroutine.resume(dap_run_co, input)
                end)
              elseif #matches == 1 then
                coroutine.resume(dap_run_co, matches[1])
              else
                vim.ui.select(matches, {
                  prompt = 'Select build output:',
                }, function(choice)
                  coroutine.resume(dap_run_co, choice)
                end)
              end
            end)
          end)
        end,
        cwd = function()
          return last_project_dir or vim.fn.getcwd()
        end,
        stopAtEntry = false,
      },
    }
  end,
}
