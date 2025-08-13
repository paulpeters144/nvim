-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.g.snacks_animate = false
vim.opt.relativenumber = false

if vim.fn.executable("pwsh") == 1 then
  vim.o.shell = "pwsh"
else
  vim.o.shell = "powershell"
end

vim.o.shellcmdflag =
  "-NoLogo -ExecutionPolicy RemoteSigned -Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.UTF8Encoding]::new();$PSDefaultParameterValues['Out-File:Encoding']='utf8';"

vim.o.shellredir = '2>&1 | %{ "$_" } | Out-File %s; exit $LastExitCode'

vim.o.shellpipe = '2>&1 | %{ "$_" } | Tee-Object %s; exit $LastExitCode'

vim.o.shellquote = ""
vim.o.shellxquote = ""

-- vim.opt.guifont = { "JetBrainsMono Nerd Font", ":h13" }

-- copy path command
vim.api.nvim_create_user_command("CPath", function()
  vim.fn.setreg("+", vim.fn.expand("%:p"))
  print("File path copied to clipboard!")
end, { desc = "Copy the current file path to clipboard" })
