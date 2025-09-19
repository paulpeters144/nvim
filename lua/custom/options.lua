vim.opt.tabstop = 2 -- show tabs as 2 spaces
vim.opt.shiftwidth = 2 -- indent by 2 spaces
vim.opt.expandtab = true -- convert tabs to spaces
vim.opt.autoindent = true
vim.opt.smartindent = true

vim.o.number = true
vim.o.mouse = 'a'
vim.o.showmode = false
vim.schedule(function()
  vim.o.clipboard = 'unnamedplus'
end)

vim.o.breakindent = true
vim.o.undofile = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.signcolumn = 'yes'
vim.o.updatetime = 250
vim.o.timeoutlen = 300
vim.o.splitright = true
vim.o.splitbelow = true
vim.o.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
vim.o.inccommand = 'split'
vim.o.cursorline = true
vim.o.scrolloff = 10
vim.o.confirm = true
vim.opt.wrap = false

vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})

vim.g.snacks_animate = false
vim.opt.relativenumber = false

if vim.fn.executable 'pwsh' == 1 then
  vim.o.shell = 'pwsh'
else
  vim.o.shell = 'powershell'
end

vim.o.shellcmdflag =
  "-NoLogo -ExecutionPolicy RemoteSigned -Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.UTF8Encoding]::new();$PSDefaultParameterValues['Out-File:Encoding']='utf8';"

vim.o.shellredir = '2>&1 | %{ "$_" } | Out-File %s; exit $LastExitCode'

vim.o.shellpipe = '2>&1 | %{ "$_" } | Tee-Object %s; exit $LastExitCode'

vim.o.shellquote = ''
vim.o.shellxquote = ''

-- vim.opt.guifont = { "JetBrainsMono Nerd Font", ":h13" }

-- copy path command
vim.api.nvim_create_user_command('CPath', function()
  vim.fn.setreg('+', vim.fn.expand '%:p')
  print 'File path copied to clipboard!'
end, { desc = 'Copy the current file path to clipboard' })
