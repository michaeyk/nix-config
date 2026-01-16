#!/bin/env bash

WALLPAPER_DIR="$HOME/Pictures/wallpaper/"
# Get the name of the focused monitor with hyprctl
FOCUSED_MONITOR=$(hyprctl monitors -j | jq -r '.[] | select(.focused) | .name')
# Get a random wallpaper
WALLPAPER=$(find "$WALLPAPER_DIR" -type f | shuf -n 1)

# Apply the selected wallpaper using new hyprpaper IPC syntax
hyprctl hyprpaper wallpaper "$FOCUSED_MONITOR, $WALLPAPER"
