return {
  'mrcjkb/rustaceanvim',
  version = '^9', -- Recommended
  lazy = false, -- This plugin is already lazy
  dependencies = { 'mason-org/mason.nvim' },
  ft = { 'rust' },
  opts = {
    server = {
      on_attach = function(_, bufnr) end,
      default_settings = {
        -- rust-analyzer language server configuration
        ['rust-analyzer'] = {
          cargo = {
            allFeatures = true,
            loadOutDirsFromCheck = true,
            buildScripts = {
              enable = true,
            },
          },
          -- Add clippy lints for Rust if using rust-analyzer
          checkOnSave = true,
          check = {
            command = 'clippy',
            extraArgs = { '--no-deps' },
          },
          procMacro = {
            enable = true,
          },
        },
      },
    },
  },
  config = function(_, opts)
    local mason_path = vim.fn.stdpath 'data' .. '/mason/packages/codelldb/extension/'
    local codelldb_path, liblldb_path

    if vim.fn.has 'win32' == 1 then
      local extension_path = mason_path:gsub('/', '\\')
      codelldb_path = extension_path .. 'adapter\\codelldb.exe'
      liblldb_path = extension_path .. 'lldb\\bin\\liblldb.dll'
    else
      codelldb_path = mason_path .. 'adapter/codelldb'
      liblldb_path = mason_path .. 'lldb/lib/liblldb.dylib'
    end

    -- If the file exists, configure the adapter
    if vim.fn.filereadable(codelldb_path) == 1 and vim.fn.filereadable(liblldb_path) == 1 then
      local adapter = require('rustaceanvim.config').get_codelldb_adapter(codelldb_path, liblldb_path)
      opts.dap = {
        adapter = adapter,
      }
    else
      vim.notify('codelldb or liblldb not found. Debugging might not work. Run :MasonInstall codelldb', vim.log.levels.WARN)
    end

    vim.g.rustaceanvim = vim.tbl_deep_extend('keep', vim.g.rustaceanvim or {}, opts or {})
  end,
}
