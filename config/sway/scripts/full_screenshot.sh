#!/usr/bin/bash

# Takes a screenshot of whole screen
# Copies to clipboard
# Saves to screenshot folder
# Intended to be used for keybindings

grim - | tee >(wl-copy) >(grim_output=$(date +Screenshot_%Y-%m-%d_%H:%M:%S_Workspace_$(hyprctl activewindow -j | jq '.workspace.name' | tr -d '"').png) && mv /tmp/$grim_output /home/david/Pictures/Screenshots/$grim_output)