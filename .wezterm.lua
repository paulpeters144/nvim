-- Pull in the wezterm API
local wezterm = require 'wezterm'
local act = wezterm.action
local config = wezterm.config_builder()

-- =========================================================
-- 🎨 APPEARANCE & VIBES
-- =========================================================
config.color_scheme = 'Catppuccin Mocha'
config.window_background_opacity = 0.85

-- Platform-specific appearance
local is_macos = wezterm.target_triple:find 'apple-darwin'
local is_windows = wezterm.target_triple:find 'windows'
if is_macos then
  config.macos_window_background_blur = 30
end
if is_windows then
  config.win32_system_backdrop = 'Acrylic'
end

config.window_decorations = 'RESIZE'

config.font = wezterm.font 'JetBrainsMono Nerd Font Mono'
config.font_size = 11.0
config.harfbuzz_features = { 'calt=0', 'clig=0', 'liga=0' }

config.window_padding = {
  left = 0,
  right = 0,
  top = 0,
  bottom = 0,
}

config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = false
config.hide_tab_bar_if_only_one_tab = false
config.tab_max_width = 32
config.colors = {
  tab_bar = {
    background = '#1e1e2e',
  },
}

-- =========================================================
-- 🧩 HARDWARE & PERFORMANCE
-- =========================================================
config.front_end = 'WebGpu'
config.max_fps = 120
config.default_cursor_style = 'BlinkingBar'
config.animation_fps = 1
config.cursor_blink_rate = 500
config.term = 'xterm-256color'
config.prefer_egl = true

-- =========================================================
-- ⌨️ KEYBINDINGS (Vim-Style)
-- =========================================================

-- 1. Define the Leader Key
-- This is common in Vim/Tmux. Press Ctrl+B, release, then press the next key.
config.leader = { key = 'Space', mods = 'CTRL', timeout_milliseconds = 1000 }

config.keys = {
  -- 2. Send "Ctrl-B" to the terminal when pressed twice
  { key = 'b', mods = 'LEADER|CTRL', action = act.SendKey { key = 'b', mods = 'CTRL' } },

  -- 3. Pane Navigation (Vim Motions)
  -- "h" = Left, "j" = Down, "k" = Up, "l" = Right
  { key = 'h', mods = 'LEADER', action = act.ActivatePaneDirection 'Left' },
  { key = 'j', mods = 'LEADER', action = act.ActivatePaneDirection 'Down' },
  { key = 'k', mods = 'LEADER', action = act.ActivatePaneDirection 'Up' },
  { key = 'l', mods = 'LEADER', action = act.ActivatePaneDirection 'Right' },

  -- 4. Pane Splitting
  -- Think: "s" for "split" (horizontal line), "v" for "vertical" (vertical line)
  { key = 's', mods = 'LEADER', action = act.SplitVertical { domain = 'CurrentPaneDomain' } },
  { key = 'v', mods = 'LEADER', action = act.SplitHorizontal { domain = 'CurrentPaneDomain' } },

  -- 5. Tabs
  { key = 'c', mods = 'LEADER', action = act.SpawnTab 'CurrentPaneDomain' }, -- "c" for Create
  { key = 'x', mods = 'LEADER', action = act.CloseCurrentPane { confirm = true } }, -- "x" to Kill
  { key = 'n', mods = 'LEADER', action = act.ActivateTabRelative(1) }, -- "n" for Next
  { key = 'p', mods = 'LEADER', action = act.ActivateTabRelative(-1) }, -- "p" for Previous

  -- 6. Copy Mode (Vim style scrolling)
  { key = '[', mods = 'LEADER', action = act.ActivateCopyMode },

  -- 7. Enter Resize Mode
  {
    key = 'r',
    mods = 'LEADER',
    action = act.ActivateKeyTable {
      name = 'resize_pane',
      one_shot = false,
    },
  },

  -- Toggle Opacity
  {
    key = 'u', -- "u" for "Unfocus/Undo" opacity? Just a random binding.
    mods = 'LEADER',
    action = wezterm.action_callback(function(window, _)
      local overrides = window:get_config_overrides() or {}
      if overrides.window_background_opacity == 1.0 then
        overrides.window_background_opacity = 0.85
      else
        overrides.window_background_opacity = 1.0
      end
      window:set_config_overrides(overrides)
    end),
  },

  {
    key = 'R',
    mods = 'LEADER',
    action = act.PromptInputLine {
      description = 'Enter new name for tab',
      action = wezterm.action_callback(function(window, pane, line)
        if line then
          window:active_tab():set_title(line)
        end
      end),
    },
  },
}

-- =========================================================
-- 📐 RESIZE KEY TABLE
-- =========================================================
-- This creates a temporary "mode" where you don't need to hold CTRL/ALT
config.key_tables = {
  resize_pane = {
    { key = 'h', action = act.AdjustPaneSize { 'Left', 1 } },
    { key = 'j', action = act.AdjustPaneSize { 'Down', 1 } },
    { key = 'k', action = act.AdjustPaneSize { 'Up', 1 } },
    { key = 'l', action = act.AdjustPaneSize { 'Right', 1 } },
    { key = 'Escape', action = 'PopKeyTable' },
    { key = 'Enter', action = 'PopKeyTable' },
  },
}

-- =========================================================
-- 💅 CUSTOM TAB BAR LOGIC
-- =========================================================
wezterm.on('format-tab-title', function(tab, tabs, panes, config, hover, max_width)
  local background = '#1e1e2e'
  local foreground = '#a6adc8'

  if tab.is_active then
    background = '#89b4fa'
    foreground = '#11111b'
  elseif hover then
    background = '#313244'
    foreground = '#cdd6f4'
  end

  -- logic to prioritize the tab title if you renamed it
  local title = tab.tab_title
  if not title or #title == 0 then
    title = tab.active_pane.title
  end

  local edge_background = '#1e1e2e'

  return {
    { Background = { Color = edge_background } },
    { Foreground = { Color = background } },
    { Text = '' },
    { Background = { Color = background } },
    { Foreground = { Color = foreground } },
    -- Use our new 'title' variable here:
    { Text = ' ' .. tab.tab_index + 1 .. ': ' .. title .. ' ' },
    { Background = { Color = edge_background } },
    { Foreground = { Color = background } },
    { Text = '' },
    { Text = ' ' },
  }
end)

-- Platform-specific default shell
if is_windows then
  config.default_prog = { 'powershell.exe', '-NoLogo' }
else
  config.default_prog = { '/bin/zsh', '-l' }
end

return config
