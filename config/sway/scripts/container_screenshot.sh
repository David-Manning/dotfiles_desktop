#!/bin/bash

#!/bin/bash
grim_output="$HOME/Pictures/Screenshots/$(date +%Y-%m-%d-%H%M%S).png"
geometry=$(swaymsg -t get_tree | jq -r '.. | select(.focused?) | .rect | "\(.x),\(.y) \(.width)x\(.height)"')
mkdir -p "$(dirname "$grim_output")" && grim -g "$geometry" - | tee "$grim_output" | wl-copy || notify-send -u critical "Screenshot failed"
