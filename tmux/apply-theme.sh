#!/bin/bash
# Applies the correct tmux theme based on environment.
# Called on tmux client-attached hook so theme is always correct on attach.

if [ -f ~/.cache/win365 ]; then
    tmux source ~/.config/tmux/themes/catppuccin-mocha.conf
else
    val=$(reg.exe query "HKCU\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" \
        /v AppsUseLightTheme 2>/dev/null | grep -o "0x[0-9a-fA-F]*" | tail -1)
    if [ "$((${val:-0}))" = "1" ] 2>/dev/null; then
        tmux source ~/.config/tmux/themes/catppuccin-latte.conf
    else
        tmux source ~/.config/tmux/themes/catppuccin-mocha.conf
    fi
fi
