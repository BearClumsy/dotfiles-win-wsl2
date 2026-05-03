local wezterm = require 'wezterm'
local config = wezterm.config_builder()


-- Shell: launch WSL2
config.default_prog = { 'wsl.exe', '--', 'zsh', '-l' }

-- Pass flag into WSL so .zshrc loads Oh My Zsh + Powerlevel10k
config.set_environment_variables = {
  WEZTERM_USE_OMZ = '1',
  WSLENV = 'WEZTERM_USE_OMZ/u',
}

-- Prevent raw escape sequences leaking into apps (e.g. yazi) inside tmux
config.term = 'xterm-256color'

-- Font
config.font = wezterm.font('Hack Nerd Font Mono')
config.font_size = 13.0

config.color_scheme = 'Catppuccin Mocha'

-- Window (no opacity — RDP does not support window compositing)
config.window_padding = { left = 6, right = 6, top = 6, bottom = 6 }
config.initial_cols = 100
config.initial_rows = 30
config.window_decorations = 'TITLE | RESIZE'
config.enable_tab_bar = false

-- Windows 365 (Cloud PC): use software rendering to avoid GPU virtualisation issues
config.front_end = 'Gdi'
config.enable_wayland = false

-- Performance: reduce rendering overhead in software mode + RDP bandwidth
config.max_fps = 30
config.animation_fps = 1
config.cursor_blink_rate = 0
config.harfbuzz_features = { 'calt=0', 'clig=0', 'liga=0' }
config.scrollback_lines = 3500
config.font_shaper = 'AllSorts'
config.use_ime = false
config.audible_bell = 'Disabled'

-- Key bindings
config.keys = {
  { key = 'C', mods = 'CTRL|SHIFT', action = wezterm.action.CopyTo 'Clipboard' },
  { key = 'V', mods = 'CTRL|SHIFT', action = wezterm.action.PasteFrom 'Clipboard' },
}

return config
