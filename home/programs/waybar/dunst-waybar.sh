#!/bin/bash

# Get dunst status
paused=$(dunstctl is-paused)
count=$(dunstctl count history)

# Set icon based on status
if [ "$paused" = "true" ]; then
    icon="dnd"
    tooltip="Do Not Disturb enabled"
else
    icon="default"
    if [ "$count" -gt 0 ]; then
        tooltip="$count unread notification(s)"
    else
        tooltip="No unread notifications"
    fi
fi

# Output JSON for waybar
echo "{\"text\":\"$count\",\"alt\":\"$icon\",\"tooltip\":\"$tooltip\",\"class\":\"$icon\"}"