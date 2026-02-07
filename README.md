# 🚀 personal nvim

A modular, high-performance Neovim configuration built on top of [kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim), optimized for Windows and specialized for web development and C#.

## 🛠️ Features

- **Package Manager**: [lazy.nvim](https://github.com/folke/lazy.nvim) for fast, concurrent plugin loading.
- **LSP**: Integrated Language Server Protocol support via [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig) and [Mason](https://github.com/williamboman/mason.nvim) for easy management of servers.
  - Pre-configured for: TypeScript (`ts_ls`), C# (`roslyn`), and Lua (`lua_ls`).
- **Completion**: [blink.cmp](https://github.com/Saghen/blink.cmp) for ultra-fast autocompletion with snippet support via [LuaSnip](https://github.com/L3MON4D3/LuaSnip).
- **Fuzzy Finder**: [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) for powerful searching across files, buffers, and symbols.
- **Treesitter**: [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) for superior syntax highlighting and code understanding.
- **File Management**: [oil.nvim](https://github.com/stevearc/oil.nvim) for editing the file system like a normal Neovim buffer.
- **Terminal**: [toggleterm.nvim](https://github.com/akinsho/toggleterm.nvim) for seamless terminal integration.
- **Git**: [neogit](https://github.com/NeogitOrg/neogit) and [gitsigns.nvim](https://github.com/lewis6991/gitsigns.nvim) for a complete Git workflow.
- **Session Management**: [persistence.nvim](https://github.com/folke/persistence.nvim) to automatically save and restore sessions.
- **UI Enhancements**:
  - `which-key.nvim` for discovering keybindings.
  - `mini.nvim` modules for various utilities.
  - `scrollbar.nvim` for visual context.
  - `smear-cursor.nvim` for smooth cursor transitions.

## ⌨️ Keymaps

The leader key is set to `<Space>`.

### General
- `-`: Open [Oil](https://github.com/stevearc/oil.nvim) (parent directory).
- `<leader>tt`: Toggle Terminal.
- `<Esc>`: Clear search highlights.
- `<C-h/j/k/l>`: Move focus between windows.

### Buffers
- `<leader>bn`: Next buffer.
- `<leader>bp`: Previous buffer.
- `<leader>bd`: Delete current buffer (with save confirmation).
- `<S-h>`: Open Telescope buffer switcher.

### Search (Telescope)
- `<leader><leader>`: Find files.
- `<leader>sg`: Live grep.
- `<leader>sw`: Search current word.
- `<leader>sh`: Search help tags.

### LSP
- `<leader>cd`: Go to Definition.
- `<leader>cr`: Rename symbol.
- `<leader>ca`: Code Action.
- `<leader>cR`: References.

## 💻 Windows Support

This configuration is specifically tuned for Windows performance:
- Automatically detects and uses `pwsh` or `powershell`.
- Optimized shell flags for UTF-8 encoding and error handling.
- Custom clipboard integration.

## 📁 Structure

```text
.
├── init.lua              # Main entry point
├── lua/
│   ├── custom/
│   │   ├── keymaps.lua   # Custom keybindings
│   │   ├── options.lua   # Vim options (tabs, shell, etc.)
│   │   └── health.lua    # Health checks
│   └── plugins/          # Plugin-specific configurations
└── snippets/             # Custom code snippets
```

## 🚀 Getting Started

1. Install Neovim (v0.10+ recommended).
2. Clone this repository into `%LOCALAPPDATA%\nvim`.
3. Start Neovim; `lazy.nvim` will automatically install the plugins.
4. Ensure you have a C compiler (like `gcc` or `clang`) and `make` installed for building native extensions (like `fzf-native`).