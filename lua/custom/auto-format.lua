local M = {}

local function replace_lines(bufnr, new_lines)
  local win = vim.api.nvim_get_current_win()
  if vim.api.nvim_win_get_buf(win) ~= bufnr then
    win = nil
  end
  local cursor = win and vim.api.nvim_win_get_cursor(win)

  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, new_lines)

  if win and cursor then
    local line_count = vim.api.nvim_buf_line_count(bufnr)
    local row = math.min(cursor[1], line_count)
    local line = vim.api.nvim_buf_get_lines(bufnr, row - 1, row, false)[1] or ''
    local col = math.min(cursor[2] + 1, #line + 1)
    vim.api.nvim_win_set_cursor(win, { row, math.max(col - 1, 0) })
  end
end

local function file_type_is(path, ...)
  local extension = '.' .. vim.fn.fnamemodify(path, ':e'):lower()
  for _, ext in ipairs { ... } do
    if extension == ext then return true end
  end
  return false
end

local function lines_from_stdout(stdout)
  stdout = (stdout or ''):gsub('\r\n', '\n'):gsub('\r', '\n')
  local new_lines = vim.split(stdout, '\n', { plain = true })
  if new_lines[#new_lines] == '' then
    table.remove(new_lines)
  end
  return new_lines
end

-- Formatters read the buffer on stdin and print the result. They must not
-- write the file: a write here changes the mtime, and the :w that follows
-- then warns that the file changed since it was read.
local function format_stdin(bufnr, label, cmd, opts)
  opts = opts or {}
  local path = vim.api.nvim_buf_get_name(bufnr)
  if path == '' then return end

  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local content = table.concat(lines, '\n')
  if vim.bo[bufnr].eol and #lines > 0 then
    content = content .. '\n'
  end

  local sys_opts = { stdin = content }
  if opts.cwd then
    sys_opts.cwd = opts.cwd
  end

  local ok, result = pcall(vim.system, cmd, sys_opts)
  if not ok then
    vim.notify('auto-format: ' .. label .. ' failed: ' .. tostring(result), vim.log.levels.WARN)
    return
  end

  result = result:wait()
  if result.code ~= 0 then
    vim.notify('auto-format: ' .. label .. ' failed', vim.log.levels.WARN)
    return
  end

  local new_lines = lines_from_stdout(result.stdout)
  if #new_lines == 0 and #lines > 0 then return end
  replace_lines(bufnr, new_lines)
end

local function format_go(bufnr)
  format_stdin(bufnr, 'go', { 'gofmt' })
end

local function format_rust(bufnr)
  local path = vim.api.nvim_buf_get_name(bufnr)
  -- rustfmt only walks parent dirs for rustfmt.toml when cwd is the file's directory.
  format_stdin(bufnr, 'rust', { 'rustfmt', '--edition', '2021', '--emit', 'stdout' }, {
    cwd = vim.fs.dirname(path),
  })
end

local function format_dart(bufnr)
  local path = vim.api.nvim_buf_get_name(bufnr)
  format_stdin(bufnr, 'dart', { 'dart', 'format', '--stdin-name', path, '--output', 'show' })
end

local function format_python(bufnr)
  local path = vim.api.nvim_buf_get_name(bufnr)
  format_stdin(bufnr, 'python', { 'black', '--quiet', '-' }, {
    cwd = vim.fs.dirname(path),
  })
end

local function format_toml(bufnr)
  local path = vim.api.nvim_buf_get_name(bufnr)
  format_stdin(bufnr, 'toml', { 'taplo', 'fmt', '--stdin-filepath', path, '-' })
end

local function format_lua(bufnr)
  local path = vim.api.nvim_buf_get_name(bufnr)
  format_stdin(bufnr, 'lua', { 'stylua', '--stdin-filepath', path, '-' })
end

local biome_config_names = { 'biome.json', 'biome.jsonc' }
local prettier_config_names = {
  '.prettierrc',
  '.prettierrc.json',
  '.prettierrc.yaml',
  '.prettierrc.yml',
  '.prettierrc.toml',
  '.prettierrc.js',
  '.prettierrc.cjs',
  '.prettierrc.mjs',
  'prettier.config.js',
  'prettier.config.cjs',
  'prettier.config.mjs',
}

local function resolve_formatter(path)
  local dir = vim.fs.dirname(path)
  while dir do
    for _, name in ipairs(biome_config_names) do
      if vim.uv.fs_stat(vim.fs.joinpath(dir, name)) then
        if vim.fn.executable('biome') == 1 then
          return 'biome'
        end
      end
    end
    for _, name in ipairs(prettier_config_names) do
      if vim.uv.fs_stat(vim.fs.joinpath(dir, name)) then
        if vim.fn.executable('prettier') == 1 then
          return 'prettier'
        end
      end
    end
    local pkg = vim.fs.joinpath(dir, 'package.json')
    if vim.uv.fs_stat(pkg) then
      local ok, decoded = pcall(vim.json.decode, table.concat(vim.fn.readfile(pkg), '\n'))
      if ok and type(decoded) == 'table' then
        local dependencies = type(decoded.dependencies) == 'table' and decoded.dependencies or {}
        local dev_dependencies = type(decoded.devDependencies) == 'table' and decoded.devDependencies or {}
        local deps = vim.tbl_extend('force', dependencies, dev_dependencies)
        if deps['@biomejs/biome'] and vim.fn.executable('biome') == 1 then
          return 'biome'
        end
        if deps.prettier and vim.fn.executable('prettier') == 1 then
          return 'prettier'
        end
      end
    end
    local parent = vim.fs.dirname(dir)
    if parent == dir then break end
    dir = parent
  end
  return nil
end

local function format_web(bufnr)
  local path = vim.api.nvim_buf_get_name(bufnr)
  if path == '' then return end

  local formatter = resolve_formatter(path)
  if formatter == 'biome' then
    format_stdin(bufnr, 'biome', { 'biome', 'format', '--stdin-file-path', path })
  elseif formatter == 'prettier' then
    format_stdin(bufnr, 'prettier', { 'prettier', '--stdin-filepath', path })
  else
    if file_type_is(path, '.json') then return end
    local ok, err = pcall(vim.lsp.buf.format, {
      bufnr = bufnr,
      async = false,
      timeout_ms = 2000,
      filter = function(client) return client.name == 'ts_ls' end,
    })
    if not ok then
      vim.notify('auto-format: ts_ls formatting failed: ' .. tostring(err), vim.log.levels.WARN)
    end
  end
end

local function format_yaml(bufnr)
  local path = vim.api.nvim_buf_get_name(bufnr)
  format_stdin(bufnr, 'yaml', { 'prettier', '--stdin-filepath', path })
end

local function format_cs(bufnr)
  local has_formatter = false
  for _, client in ipairs(vim.lsp.get_clients { bufnr = bufnr }) do
    if client:supports_method(vim.lsp.protocol.Methods.textDocument_formatting, bufnr) then
      has_formatter = true
      break
    end
  end
  if not has_formatter then
    vim.notify('auto-format: no C# LSP client with formatting attached', vim.log.levels.WARN)
    return
  end

  local ok, err = pcall(vim.lsp.buf.format, { bufnr = bufnr, async = false, timeout_ms = 5000 })
  if not ok then
    vim.notify('auto-format: LSP formatting failed: ' .. tostring(err), vim.log.levels.WARN)
  end
end

vim.api.nvim_create_autocmd('BufWritePre', {
  callback = function(args)
    local bufnr = args.buf
    local path = vim.api.nvim_buf_get_name(bufnr)
    if path == '' then return end

    if file_type_is(path, '.go') then
      format_go(bufnr)
    elseif file_type_is(path, '.rs') then
      format_rust(bufnr)
    elseif file_type_is(path, '.dart') then
      format_dart(bufnr)
    elseif file_type_is(path, '.py') then
      format_python(bufnr)
    elseif file_type_is(path, '.toml') then
      format_toml(bufnr)
    elseif file_type_is(path, '.lua') then
      format_lua(bufnr)
    elseif file_type_is(path, '.js', '.jsx', '.ts', '.tsx', '.json') then
      format_web(bufnr)
    elseif file_type_is(path, '.yaml', '.yml') then
      format_yaml(bufnr)
    elseif file_type_is(path, '.cs') then
      format_cs(bufnr)
    end
  end,
})

return M
