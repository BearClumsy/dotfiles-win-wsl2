local wezterm = require 'wezterm'
local config = wezterm.config_builder()

local function color_scheme()
  local appearance = wezterm.gui and wezterm.gui.get_appearance() or 'Dark'
  return appearance:find('Light') and 'Catppuccin Latte' or 'Catppuccin Mocha'
end

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

-- Colors: follow Windows system light/dark setting
config.color_scheme = color_scheme()

-- Window
config.window_background_opacity = 0.94
config.window_padding = { left = 6, right = 6, top = 6, bottom = 6 }
config.initial_cols = 100
config.initial_rows = 30
config.window_decorations = 'TITLE | RESIZE'
config.enable_tab_bar = false

-- Native Windows: use default GPU-accelerated rendering
config.front_end = 'OpenGL'

-- Key bindings
config.keys = {
  { key = 'C', mods = 'CTRL|SHIFT', action = wezterm.action.CopyTo 'Clipboard' },
  { key = 'V', mods = 'CTRL|SHIFT', action = wezterm.action.PasteFrom 'Clipboard' },
}

return config
