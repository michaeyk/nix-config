#!/bin/bash

# Get dunst status
paused=$(dunstctl is-paused)
history=$(dunstctl count history 2>/dev/null || echo "0")
displayed=$(dunstctl count displayed 2>/dev/null || echo "0")
waiting=$(dunstctl count waiting 2>/dev/null || echo "0")

# Use displayed count for currently visible notifications
count=$displayed

# Set icon based on status
if [ "$paused" = "true" ]; then
    icon="dnd"
    tooltip="Do Not Disturb enabled"
else
    icon="default"
    if [ "$count" -gt 0 ]; then
        tooltip="$count active notification(s)"
    else
        tooltip="No active notifications"
    fi
fi

# Output JSON for waybar
echo "{\"text\":\"$count\",\"alt\":\"$icon\",\"tooltip\":\"$tooltip\",\"class\":\"$icon\"}"