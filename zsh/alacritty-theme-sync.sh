#!/usr/bin/env bash
# Polls Windows system theme every 5s and updates Alacritty's theme.toml accordingly.

WIN_APPDATA=$(wslpath "$(cmd.exe /c 'echo %APPDATA%' 2>/dev/null | tr -d '\r\n')")
THEME_FILE="$WIN_APPDATA/alacritty/theme.toml"
DARK="$HOME/.dotfiles/alacritty/catppuccin-mocha.toml"
LIGHT="$HOME/.dotfiles/alacritty/catppuccin-latte.toml"

get_theme() {
  reg.exe query "HKCU\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" \
    /v AppsUseLightTheme 2>/dev/null | grep -o "0x[0-9]*" | head -1
}

CURRENT=""
mkdir -p ~/.cache

while true; do
  VALUE=$(get_theme)
  if [[ "$VALUE" == "0x1" ]]; then
    NEXT="light"
  else
    NEXT="dark"
  fi

  if [[ "$NEXT" != "$CURRENT" ]]; then
    echo "$NEXT" > ~/.cache/current-theme
    if [[ "$NEXT" == "light" ]]; then
      cp "$LIGHT" "$THEME_FILE"
      tmux source ~/.config/tmux/themes/catppuccin-latte.conf 2>/dev/null
    else
      cp "$DARK" "$THEME_FILE"
      tmux source ~/.config/tmux/themes/catppuccin-mocha.conf 2>/dev/null
    fi
    CURRENT="$NEXT"
  fi

  sleep 5
done
