#!/usr/bin/bash

# Takes a screenshot of whole screen
# Copies to clipboard
# Saves to screenshot folder
# Intended to be used for keybindings

grim_output="$HOME/Pictures/Screenshots/$(date +%Y-%m-%d-%H%M%S).png"
mkdir -p "$(dirname "$grim_output")" && grim - | tee "$grim_output" | wl-copy || notify-send -u critical "Screenshot failed"
