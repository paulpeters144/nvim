local function gopls_client(bufnr)
  return vim.lsp.get_clients({ name = 'gopls', bufnr = bufnr })[1]
end

local function apply_kind(kind)
  return function()
    vim.lsp.buf.code_action {
      context = { only = { kind }, diagnostics = {} },
      filter = function(action)
        return action.kind == kind
      end,
      apply = true,
    }
  end
end

-- gopls asks for tags and the interface name through command/resolve.
-- Neovim does not drive that handshake, so these two keys do it here.
local function ask_field(field, client, done)
  local type_info = field.type or {}
  local kind = type_info.kind or 'string'
  local prompt = field.description or 'Value'
  if field.error and field.error ~= '' then
    prompt = prompt .. ' (' .. field.error .. ')'
  end

  if kind == 'string' then
    vim.ui.input({ prompt = prompt .. ': ', default = field.default }, function(answer)
      done(answer)
    end)
  elseif kind == 'enum' then
    local entries = type_info.entries or {}
    vim.ui.select(entries, {
      prompt = prompt,
      format_item = function(item)
        return item.description or item.value
      end,
    }, function(choice)
      done(choice and choice.value or nil)
    end)
  elseif kind == 'lazyEnum' then
    vim.ui.input({ prompt = prompt .. ': ', default = field.default or '' }, function(query)
      if query == nil then
        done(nil)
        return
      end
      client:request('interactive/listEnum', {
        source = type_info.source,
        config = type_info.config,
        query = query,
      }, function(err, result)
        if err then
          vim.notify(err.message, vim.log.levels.ERROR)
          done(nil)
          return
        end
        local entries = result
        if type(result) == 'table' and result.entries then
          entries = result.entries
        end
        entries = entries or {}
        vim.schedule(function()
          if #entries == 0 then
            done(query ~= '' and query or nil)
            return
          end
          if #entries == 1 then
            done(entries[1].value)
            return
          end
          vim.ui.select(entries, {
            prompt = prompt,
            format_item = function(item)
              return item.description or item.value
            end,
          }, function(choice)
            done(choice and choice.value or nil)
          end)
        end)
      end)
    end)
  else
    vim.notify('Unsupported gopls prompt: ' .. kind, vim.log.levels.WARN)
    done(nil)
  end
end

local function ask_form(fields, client, cb)
  local answers = {}
  local function step(index)
    if index > #fields then
      cb(answers)
      return
    end
    ask_field(fields[index], client, function(answer)
      if answer == nil then
        cb(nil)
        return
      end
      answers[index] = answer
      step(index + 1)
    end)
  end
  vim.schedule(function()
    step(1)
  end)
end

local function resolve_and_run(client, bufnr, params, rounds)
  if rounds > 5 then
    vim.notify('gopls prompt did not finish', vim.log.levels.WARN)
    return
  end
  client:request('command/resolve', params, function(err, resolved)
    if err then
      vim.notify(err.message, vim.log.levels.ERROR)
      return
    end
    if not resolved then
      vim.notify('gopls returned no command', vim.log.levels.WARN)
      return
    end
    local fields = resolved.formFields
    if fields and #fields > 0 then
      ask_form(fields, client, function(answers)
        if not answers then
          return
        end
        resolved.formFields = nil
        resolved.formAnswers = answers
        resolve_and_run(client, bufnr, resolved, rounds + 1)
      end)
      return
    end
    client:request('workspace/executeCommand', {
      command = resolved.command,
      arguments = resolved.arguments,
      formAnswers = resolved.formAnswers,
    }, function(exec_err)
      if exec_err then
        vim.notify(exec_err.message, vim.log.levels.ERROR)
      end
    end, bufnr)
  end, bufnr)
end

local function interactive_kind(kind)
  return function()
    local bufnr = vim.api.nvim_get_current_buf()
    local client = gopls_client(bufnr)
    if not client then
      vim.notify('gopls is not attached', vim.log.levels.WARN)
      return
    end
    local params = vim.lsp.util.make_range_params(0, client.offset_encoding)
    params.context = {
      only = { kind },
      triggerKind = vim.lsp.protocol.CodeActionTriggerKind.Invoked,
      diagnostics = {},
    }
    client:request('textDocument/codeAction', params, function(err, result)
      if err then
        vim.notify(err.message, vim.log.levels.ERROR)
        return
      end
      local action
      for _, item in ipairs(result or {}) do
        if item.kind == kind then
          action = item
          break
        end
      end
      if not action then
        vim.notify('Nothing to do here', vim.log.levels.INFO)
        return
      end
      local function start(resolved_action)
        local cmd = resolved_action.command
        if type(cmd) ~= 'table' or not cmd.command then
          vim.notify('Nothing to do here', vim.log.levels.INFO)
          return
        end
        resolve_and_run(client, bufnr, {
          command = cmd.command,
          arguments = cmd.arguments,
        }, 1)
      end
      if not action.command and client:supports_method 'codeAction/resolve' then
        client:request('codeAction/resolve', action, function(resolve_err, resolved_action)
          if resolve_err or not resolved_action then
            vim.notify(
              resolve_err and resolve_err.message or 'Could not resolve code action',
              vim.log.levels.ERROR
            )
            return
          end
          start(resolved_action)
        end, bufnr)
      else
        start(action)
      end
    end, bufnr)
  end
end

return {
  'leoluz/nvim-dap-go',
  ft = { 'go' },
  dependencies = {
    'mfussenegger/nvim-dap',
    'nvim-neotest/nvim-nio',
  },
  opts = {
    delve = {
      detached = vim.fn.has 'win32' == 0,
      path = vim.fn.stdpath 'data' .. '/mason/packages/delve/dlv.exe',
      args = { '--check-go-version=false' },
    },
  },
  keys = {
    {
      '<leader>lgt',
      function()
        require('dap-go').debug_test()
      end,
      desc = 'Debug [T]est at cursor',
    },
    {
      '<leader>lgT',
      function()
        require('dap-go').debug_last()
      end,
      desc = 'Debug Last [T]est',
    },
    {
      '<leader>lgd',
      function()
        local dap = require 'dap'
        for _, config in ipairs(dap.configurations.go or {}) do
          if config.name == 'Debug' then
            dap.run(vim.deepcopy(config))
            return
          end
        end
        vim.notify('Go debug config "Debug" is not registered', vim.log.levels.WARN)
      end,
      desc = '[D]ebug file',
    },
    {
      '<leader>lgi',
      apply_kind 'source.organizeImports',
      desc = 'Organize [I]mports',
    },
    {
      '<leader>lgf',
      apply_kind 'refactor.rewrite.fillStruct',
      desc = '[F]ill struct',
    },
    {
      '<leader>lgj',
      interactive_kind 'refactor.rewrite.addTags',
      desc = 'Add struct tags',
    },
    {
      '<leader>lgI',
      interactive_kind 'refactor.rewrite.implementInterface',
      desc = 'Implement interface',
    },
    {
      '<leader>lgl',
      function()
        local clients = vim.lsp.get_clients { name = 'gopls' }
        if #clients == 0 then
          vim.notify('gopls is not attached', vim.log.levels.WARN)
          return
        end
        for _, client in ipairs(clients) do
          client:stop()
        end
        vim.defer_fn(function()
          vim.cmd 'silent! edit %'
          vim.notify('gopls restarted', vim.log.levels.INFO)
        end, 500)
      end,
      desc = 'Restart gopls',
    },
  },
  config = function(_, opts)
    require('dap-go').setup(opts)
  end,
}
