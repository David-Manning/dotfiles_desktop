#!/usr/bin/bash

# Takes a screenshot of whole screen
# Copies to clipboard
# Saves to screenshot folder
# Intended to be used for keybindings

grim_output="$HOME/Pictures/Screenshots/Screenshot_$(date +%Y-%m-%d_%H:%M:%S).png"
if mkdir -p "$(dirname "$grim_output")" && grim - | tee "$grim_output" | wl-copy; then
    notify-send "Screenshot saved" "$grim_output"
else
    notify-send -u critical "Screenshot failed"
fi
