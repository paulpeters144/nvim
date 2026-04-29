local ls = require 'luasnip'
local s = ls.snippet
local sn = ls.snippet_node
local i = ls.insert_node
local f = ls.function_node
local d = ls.dynamic_node
local fmt = require('luasnip.extras.fmt').fmt

-- Helper to normalize paths to forward slashes and remove trailing slash
local function normalize(path)
  if not path or path == '' then
    return ''
  end
  path = path:gsub('\\', '/')
  path = path:gsub('/$', '')
  return path
end

local function calculate_csharp_namespace()
  local filepath = normalize(vim.fn.expand '%:p:h')
  local current_file = normalize(vim.fn.expand '%:p')

  -- 1. Try to find a namespace by reading sibling .cs files
  local sibling_cs_files = vim.fn.glob(filepath .. '/*.cs', false, true)
  if type(sibling_cs_files) == 'table' then
    for _, file in ipairs(sibling_cs_files) do
      local normalized_file = normalize(file)
      if normalized_file ~= current_file and vim.fn.filereadable(file) == 1 then
        local lines = vim.fn.readfile(file)
        if lines then
          for _, line in ipairs(lines) do
            local ns = line:match 'namespace%s+([^;{]+)'
            if ns then
              return ns:gsub('^%s+', ''):gsub('%s+$', '')
            end
          end
        end
      end
    end
  end

  -- 2. Fallback: Search upward for the .csproj file manually
  local current_dir = filepath
  local csproj_file = nil

  while current_dir and current_dir ~= '' do
    local files = vim.fn.glob(current_dir .. '/*.csproj', false, true)
    if type(files) == 'table' and #files > 0 then
      csproj_file = normalize(files[1])
      break
    end

    local parent_dir = normalize(vim.fn.fnamemodify(current_dir, ':h'))
    -- Break if we reached the root (e.g., C:/ parent is C:/)
    if parent_dir == current_dir then
      break
    end
    current_dir = parent_dir
  end

  if csproj_file then
    local csproj_dir = normalize(vim.fn.fnamemodify(csproj_file, ':h'))
    local csproj_name = vim.fn.fnamemodify(csproj_file, ':t:r')

    if filepath == csproj_dir then
      return csproj_name
    end

    local filepath_lower = filepath:lower()
    local csproj_dir_lower = csproj_dir:lower()

    -- Check if filepath starts with csproj_dir
    if filepath_lower:sub(1, #csproj_dir_lower) == csproj_dir_lower then
      -- Extract the part after the project directory
      local relative_dir = filepath:sub(#csproj_dir + 2)
      if relative_dir ~= '' then
        -- Replace slashes with dots
        local namespace_suffix = relative_dir:gsub('/', '.')
        return csproj_name .. '.' .. namespace_suffix
      end
      return csproj_name
    end
  end

  return 'Namespace'
end

local function get_namespace_declaration()
  -- Check if there's already a namespace in the current buffer
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  for _, line in ipairs(lines) do
    if line:match('^%s*namespace%s+') then
      return "" -- Return empty string if namespace exists
    end
  end

  -- If not, generate the namespace declaration with trailing blank lines
  local ns = calculate_csharp_namespace()
  return { "namespace " .. ns .. ";", "", "" }
end

local function dynamic_type_name(args, parent)
  local name = vim.fn.expand '%:t:r'
  -- Extract only the part before the first dot to ensure a valid C# type name
  local sanitized = name:match '^([^.]+)'
  if not sanitized or sanitized == '' then
    sanitized = 'MyType'
  end
  return sn(nil, { i(1, sanitized) })
end

return {
  s(
    { trig = 'class', priority = 2000 },
    fmt(
      [[
        {}public class {}
        {{
            {}
        }}
    ]],
      {
        f(get_namespace_declaration),
        d(1, dynamic_type_name),
        i(0),
      }
    )
  ),
  s(
    { trig = 'record', priority = 2000 },
    fmt(
      [[
        {}public record {}
        {{
            {}
        }}
    ]],
      {
        f(get_namespace_declaration),
        d(1, dynamic_type_name),
        i(0),
      }
    )
  ),
  s(
    { trig = 'struct', priority = 2000 },
    fmt(
      [[
        {}public struct {}
        {{
            {}
        }}
    ]],
      {
        f(get_namespace_declaration),
        d(1, dynamic_type_name),
        i(0),
      }
    )
  ),
  s(
    { trig = 'enum', priority = 2000 },
    fmt(
      [[
        {}public enum {}
        {{
            {}
        }}
    ]],
      {
        f(get_namespace_declaration),
        d(1, dynamic_type_name),
        i(0),
      }
    )
  ),
}
