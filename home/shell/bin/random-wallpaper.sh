#!/bin/env bash

WALLPAPER_DIR="$HOME/Pictures/wallpaper/"
# Get a random wallpaper
WALLPAPER=$(find "$WALLPAPER_DIR" -type f | shuf -n 1)

# Apply the selected wallpaper using swww
swww img "$WALLPAPER" --transition-type fade --transition-duration 1
