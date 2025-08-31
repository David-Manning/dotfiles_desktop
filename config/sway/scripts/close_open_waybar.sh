#!/bin/bash

# Order matters because it looks more logical this way - close Waybar, close Sway, open Sway, open Waybar
# Close all instances of Waybar
# Close and reopen Sway
# Start Waybar again

killall waybar
killall dunst
swaymsg reload
dunst
waybar

