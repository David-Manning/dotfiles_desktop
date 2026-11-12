#!/usr/bin/bash

# Waybar calendar popup
# Clicking the date module toggles a GTK calendar window (yad) that stays
# open until clicked again or Escape is pressed. The GTK calendar has
# month arrows and year arrows in its top corners. Entirely local.
#
# The window is floated and positioned under the date by a for_window
# rule in ~/.config/sway/config.d/4_appearance, matched on the title.
#
# Usage:
#   calendar.sh         open the calendar if closed, close it if open
#
# Requires: yad

TITLE="waybar-calendar"
STYLE="${HOME}/.config/waybar/calendar.css"

# Already open: close it and stop
if pgrep -f -- "--title=${TITLE}" > /dev/null; then
    pkill -f -- "--title=${TITLE}"
    exit 0
fi

# Launch detached from Waybar so it keeps running after this script exits
setsid -f yad --calendar \
    --title="${TITLE}" \
    --undecorated \
    --no-buttons \
    --skip-taskbar \
    --sticky \
    --borders=10 \
    --gtkrc="${STYLE}" \
    > /dev/null 2>&1
