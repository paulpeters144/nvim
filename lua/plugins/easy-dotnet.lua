local function add_dotnet_mappings()
  local dotnet = require 'easy-dotnet'

  vim.api.nvim_create_user_command('Secrets', function()
    dotnet.secrets()
  end, {})

  vim.keymap.set('n', '<A-t>', function()
    vim.cmd 'Dotnet testrunner'
  end, { desc = '.NET [T]est Runner', nowait = true })

  vim.keymap.set('n', '<C-p>', function()
    vim.cmd 'Dotnet debug profile default'
  end, { desc = '.NET Debug [P]rofile', nowait = true })

  vim.keymap.set('n', '<leader>lns', function()
    vim.cmd 'Dotnet solution select'
  end, { desc = '[S]olution Select' })

  vim.keymap.set('n', '<leader>lnp', function()
    vim.cmd 'Dotnet project view'
  end, { desc = '[P]roject View' })

  vim.keymap.set('n', '<leader>lnr', function()
    local projects = vim.fn.globpath(vim.fn.getcwd(), '**/*.csproj', 0, 1)
    if #projects == 0 then
      vim.notify('No projects found', vim.log.levels.WARN)
      return
    end

    local function run_project(path)
      local cwd = vim.fn.fnamemodify(path, ':h')
      require('toggleterm').exec(string.format('dotnet run --project "%s"\r', path), nil, nil, cwd, 'float') 
    end

    if #projects == 1 then
      run_project(projects[1])
    else
      vim.ui.select(projects, {
        prompt = 'Select project to run:',
        format_item = function(item)
          return vim.fn.fnamemodify(item, ':t')
        end,
      }, function(path)
        if path then
          run_project(path)
        end
      end)
    end
  end, { desc = '[R]un Project' })

  vim.keymap.set('n', '<leader>lnd', function()
    -- Use manual DAP configuration instead of easy-dotnet's problematic debugger
    require('dap').continue()
  end, { desc = '[D]ebug (DAP)' })

  vim.keymap.set('n', '<leader>lnu', function()
    vim.cmd 'Dotnet _server update'
  end, { desc = 'Server [U]pdate' })

  vim.keymap.set('n', '<leader>lni', function()
    vim.cmd 'checkhealth easy-dotnet'
  end, { desc = '[I]nfo (checkhealth)' })

  vim.keymap.set('n', '<leader>lnh', function()
    vim.cmd 'Dotnet _server restart'
  end, { desc = 'Server Restart' })

  vim.keymap.set('n', '<leader>lnx', function()
    require('easy-dotnet').reset()
  end, { desc = 'Reset Plugin' })
end

return {
  'GustavEikaas/easy-dotnet.nvim',
  dependencies = { 'nvim-lua/plenary.nvim', 'nvim-telescope/telescope.nvim' },
  config = function()
    local dotnet = require 'easy-dotnet'

    local netcoredbg_path = 'netcoredbg'
    local ok, mason_registry = pcall(require, 'mason-registry')
    if ok and mason_registry.is_installed 'netcoredbg' then
      local path = vim.fn.stdpath 'data' .. '/mason/packages/netcoredbg/netcoredbg/netcoredbg.exe'
      if vim.fn.executable(path) == 1 then
        netcoredbg_path = path
      end
    end

    dotnet.setup {
      server = {
        ---@type nil | "Off" | "Critical" | "Error" | "Warning" | "Information" | "Verbose" | "All"
        log_level = 'Verbose',
        use_visual_studio = false,
      },
      test_runner = {
        enable_buffer_test_execution = true,
        viewmode = 'float',
        noBuild = false,
      },
      projx_lsp = {
        enabled = true,
      },
      notifications = {
        handler = false,
      },
      debugger = {
        bin_path = netcoredbg_path,
        console = 'internalConsole',
      },
      auto_bootstrap_namespace = {
        type = 'file_scoped',
        enabled = true,
      },
      terminal = function(path, action, args, ctx)
        -- path is the absolute path to the project file (.csproj)
        local commands = {
          run = function()
            return string.format('dotnet run --project "%s" %s', path, args)
          end,
          test = function()
            return string.format('dotnet test "%s" %s', path, args)
          end,
          restore = function()
            return string.format('dotnet restore "%s" %s', path, args)
          end,
          build = function()
            return string.format('dotnet build "%s" %s', path, args)
          end,
          watch = function()
            return string.format('dotnet watch --project "%s" %s', path, args)
          end,
        }

        local command = commands[action]() .. '\r'
        require('toggleterm').exec(command, nil, nil, nil, 'float')
      end,
    }
    add_dotnet_mappings()
  end,
}
