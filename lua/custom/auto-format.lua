local M = {}

local function build_command(args)
  local out = {}
  for i, arg in ipairs(args) do
    if i == 1 then
      out[#out + 1] = arg
    else
      out[#out + 1] = vim.fn.shellescape(arg)
    end
  end
  return table.concat(out, ' ')
end

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

local function new_file_type(path)
  local extension = vim.fn.fnamemodify(path, ':e'):lower()
  return {
    is_go = function() return extension == 'go' end,
    is_rust = function() return extension == 'rs' end,
    is_dart = function() return extension == 'dart' end,
    is_python = function() return extension == 'py' end,
    is_toml = function() return extension == 'toml' end,
    is_lua = function() return extension == 'lua' end,
    is_js = function() return extension == 'js' end,
    is_jsx = function() return extension == 'jsx' end,
    is_ts = function() return extension == 'ts' end,
    is_tsx = function() return extension == 'tsx' end,
    is_json = function() return extension == 'json' end,
    is_yaml = function() return extension == 'yaml' or extension == 'yml' end,
    is_cs = function() return extension == 'cs' end,
  }
end

local function format_go(bufnr)
  local path = vim.api.nvim_buf_get_name(bufnr)
  if path == '' then return end

  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local sep = vim.bo[bufnr].fileformat == 'dos' and '\r\n' or '\n'
  local content = table.concat(lines, sep)
  if vim.bo[bufnr].eol and #lines > 0 then content = content .. sep end
  vim.fn.writefile(content, path, 'b')

  vim.fn.system(build_command { 'gofmt', '-w', path })
  if vim.v.shell_error ~= 0 then
    vim.notify('auto-format: go failed', vim.log.levels.WARN)
    return
  end

  local new_lines = vim.fn.readfile(path)
  if #new_lines == 0 and #lines > 0 then return end
  replace_lines(bufnr, new_lines)
end

local function format_rust(bufnr)
  local path = vim.api.nvim_buf_get_name(bufnr)
  if path == '' then return end

  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local sep = vim.bo[bufnr].fileformat == 'dos' and '\r\n' or '\n'
  local content = table.concat(lines, sep)
  if vim.bo[bufnr].eol and #lines > 0 then content = content .. sep end
  vim.fn.writefile(content, path, 'b')

  vim.fn.system(build_command { 'rustfmt', '--edition', '2021', path })
  if vim.v.shell_error ~= 0 then
    vim.notify('auto-format: rust failed', vim.log.levels.WARN)
    return
  end

  local new_lines = vim.fn.readfile(path)
  if #new_lines == 0 and #lines > 0 then return end
  replace_lines(bufnr, new_lines)
end

local function format_dart(bufnr)
  local path = vim.api.nvim_buf_get_name(bufnr)
  if path == '' then return end

  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local sep = vim.bo[bufnr].fileformat == 'dos' and '\r\n' or '\n'
  local content = table.concat(lines, sep)
  if vim.bo[bufnr].eol and #lines > 0 then content = content .. sep end
  vim.fn.writefile(content, path, 'b')

  vim.fn.system(build_command { 'dart', 'format', path })
  if vim.v.shell_error ~= 0 then
    vim.notify('auto-format: dart failed', vim.log.levels.WARN)
    return
  end

  local new_lines = vim.fn.readfile(path)
  if #new_lines == 0 and #lines > 0 then return end
  replace_lines(bufnr, new_lines)
end

local function format_python(bufnr)
  local path = vim.api.nvim_buf_get_name(bufnr)
  if path == '' then return end

  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local sep = vim.bo[bufnr].fileformat == 'dos' and '\r\n' or '\n'
  local content = table.concat(lines, sep)
  if vim.bo[bufnr].eol and #lines > 0 then content = content .. sep end
  vim.fn.writefile(content, path, 'b')

  vim.fn.system(build_command { 'black', '--quiet', path })
  if vim.v.shell_error ~= 0 then
    vim.notify('auto-format: python failed', vim.log.levels.WARN)
    return
  end

  local new_lines = vim.fn.readfile(path)
  if #new_lines == 0 and #lines > 0 then return end
  replace_lines(bufnr, new_lines)
end

local function format_toml(bufnr)
  local path = vim.api.nvim_buf_get_name(bufnr)
  if path == '' then return end

  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local sep = vim.bo[bufnr].fileformat == 'dos' and '\r\n' or '\n'
  local content = table.concat(lines, sep)
  if vim.bo[bufnr].eol and #lines > 0 then content = content .. sep end
  vim.fn.writefile(content, path, 'b')

  vim.fn.system(build_command { 'taplo', 'fmt', path })
  if vim.v.shell_error ~= 0 then
    vim.notify('auto-format: toml failed', vim.log.levels.WARN)
    return
  end

  local new_lines = vim.fn.readfile(path)
  if #new_lines == 0 and #lines > 0 then return end
  replace_lines(bufnr, new_lines)
end

local function format_lua(bufnr)
  local path = vim.api.nvim_buf_get_name(bufnr)
  if path == '' then return end

  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local sep = vim.bo[bufnr].fileformat == 'dos' and '\r\n' or '\n'
  local content = table.concat(lines, sep)
  if vim.bo[bufnr].eol and #lines > 0 then content = content .. sep end
  vim.fn.writefile(content, path, 'b')

  vim.fn.system(build_command { 'stylua', path })
  if vim.v.shell_error ~= 0 then
    vim.notify('auto-format: lua failed', vim.log.levels.WARN)
    return
  end

  local new_lines = vim.fn.readfile(path)
  if #new_lines == 0 and #lines > 0 then return end
  replace_lines(bufnr, new_lines)
end

local function format_js(bufnr)
  local path = vim.api.nvim_buf_get_name(bufnr)
  if path == '' then return end

  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local sep = vim.bo[bufnr].fileformat == 'dos' and '\r\n' or '\n'
  local content = table.concat(lines, sep)
  if vim.bo[bufnr].eol and #lines > 0 then content = content .. sep end
  vim.fn.writefile(content, path, 'b')

  vim.fn.system(build_command { 'prettier', '--write', path })
  if vim.v.shell_error ~= 0 then
    vim.notify('auto-format: js failed', vim.log.levels.WARN)
    return
  end

  local new_lines = vim.fn.readfile(path)
  if #new_lines == 0 and #lines > 0 then return end
  replace_lines(bufnr, new_lines)
end

local function format_jsx(bufnr)
  local path = vim.api.nvim_buf_get_name(bufnr)
  if path == '' then return end

  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local sep = vim.bo[bufnr].fileformat == 'dos' and '\r\n' or '\n'
  local content = table.concat(lines, sep)
  if vim.bo[bufnr].eol and #lines > 0 then content = content .. sep end
  vim.fn.writefile(content, path, 'b')

  vim.fn.system(build_command { 'prettier', '--write', path })
  if vim.v.shell_error ~= 0 then
    vim.notify('auto-format: jsx failed', vim.log.levels.WARN)
    return
  end

  local new_lines = vim.fn.readfile(path)
  if #new_lines == 0 and #lines > 0 then return end
  replace_lines(bufnr, new_lines)
end

local function format_ts(bufnr)
  local path = vim.api.nvim_buf_get_name(bufnr)
  if path == '' then return end

  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local sep = vim.bo[bufnr].fileformat == 'dos' and '\r\n' or '\n'
  local content = table.concat(lines, sep)
  if vim.bo[bufnr].eol and #lines > 0 then content = content .. sep end
  vim.fn.writefile(content, path, 'b')

  vim.fn.system(build_command { 'prettier', '--write', path })
  if vim.v.shell_error ~= 0 then
    vim.notify('auto-format: ts failed', vim.log.levels.WARN)
    return
  end

  local new_lines = vim.fn.readfile(path)
  if #new_lines == 0 and #lines > 0 then return end
  replace_lines(bufnr, new_lines)
end

local function format_tsx(bufnr)
  local path = vim.api.nvim_buf_get_name(bufnr)
  if path == '' then return end

  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local sep = vim.bo[bufnr].fileformat == 'dos' and '\r\n' or '\n'
  local content = table.concat(lines, sep)
  if vim.bo[bufnr].eol and #lines > 0 then content = content .. sep end
  vim.fn.writefile(content, path, 'b')

  vim.fn.system(build_command { 'prettier', '--write', path })
  if vim.v.shell_error ~= 0 then
    vim.notify('auto-format: tsx failed', vim.log.levels.WARN)
    return
  end

  local new_lines = vim.fn.readfile(path)
  if #new_lines == 0 and #lines > 0 then return end
  replace_lines(bufnr, new_lines)
end

local function format_json(bufnr)
  local path = vim.api.nvim_buf_get_name(bufnr)
  if path == '' then return end

  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local sep = vim.bo[bufnr].fileformat == 'dos' and '\r\n' or '\n'
  local content = table.concat(lines, sep)
  if vim.bo[bufnr].eol and #lines > 0 then content = content .. sep end
  vim.fn.writefile(content, path, 'b')

  vim.fn.system(build_command { 'prettier', '--write', path })
  if vim.v.shell_error ~= 0 then
    vim.notify('auto-format: json failed', vim.log.levels.WARN)
    return
  end

  local new_lines = vim.fn.readfile(path)
  if #new_lines == 0 and #lines > 0 then return end
  replace_lines(bufnr, new_lines)
end

local function format_yaml(bufnr)
  local path = vim.api.nvim_buf_get_name(bufnr)
  if path == '' then return end

  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local sep = vim.bo[bufnr].fileformat == 'dos' and '\r\n' or '\n'
  local content = table.concat(lines, sep)
  if vim.bo[bufnr].eol and #lines > 0 then content = content .. sep end
  vim.fn.writefile(content, path, 'b')

  vim.fn.system(build_command { 'prettier', '--write', path })
  if vim.v.shell_error ~= 0 then
    vim.notify('auto-format: yaml failed', vim.log.levels.WARN)
    return
  end

  local new_lines = vim.fn.readfile(path)
  if #new_lines == 0 and #lines > 0 then return end
  replace_lines(bufnr, new_lines)
end

local function format_cs(bufnr)
  local ok, err = pcall(vim.lsp.buf.format, { bufnr = bufnr, async = false, timeout_ms = 2000 })
  if not ok then
    vim.notify('auto-format: LSP formatting failed: ' .. tostring(err), vim.log.levels.WARN)
  end
end

function M.format(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local path = vim.api.nvim_buf_get_name(bufnr)
  if path == '' then return end

  local file_type = new_file_type(path)

  if file_type.is_go() then
    format_go(bufnr)
  elseif file_type.is_rust() then
    format_rust(bufnr)
  elseif file_type.is_dart() then
    format_dart(bufnr)
  elseif file_type.is_python() then
    format_python(bufnr)
  elseif file_type.is_toml() then
    format_toml(bufnr)
  elseif file_type.is_lua() then
    format_lua(bufnr)
  elseif file_type.is_js() then
    format_js(bufnr)
  elseif file_type.is_jsx() then
    format_jsx(bufnr)
  elseif file_type.is_ts() then
    format_ts(bufnr)
  elseif file_type.is_tsx() then
    format_tsx(bufnr)
  elseif file_type.is_json() then
    format_json(bufnr)
  elseif file_type.is_yaml() then
    format_yaml(bufnr)
  elseif file_type.is_cs() then
    format_cs(bufnr)
  end
end

vim.api.nvim_create_autocmd('BufWritePre', {
  callback = function(args)
    M.format(args.buf)
  end,
})

return M
