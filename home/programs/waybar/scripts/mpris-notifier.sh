#!/bin/bash

# Monitor MPRIS for track changes and send notifications

playerctl --follow metadata --format '{{ artist }} - {{ title }}' 2>/dev/null | while read -r track; do
    if [ -n "$track" ] && [ "$track" != " - " ]; then
        notify-send "🎵 Now Playing" "$track" --icon=audio-headphones
    fi
done