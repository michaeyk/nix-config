#!/bin/bash

# Get dunst status
paused=$(dunstctl is-paused)
history=$(dunstctl count history 2>/dev/null || echo "0")
displayed=$(dunstctl count displayed 2>/dev/null || echo "0")
waiting=$(dunstctl count waiting 2>/dev/null || echo "0")

# Set count and icon based on status
if [ "$paused" = "true" ]; then
    icon="dnd"
    count=$waiting
    if [ "$count" -gt 0 ]; then
        tooltip="Do Not Disturb enabled - $count message(s)"
    else
        tooltip="Do Not Disturb enabled - No messages"
    fi
else
    icon="default"
    count=$displayed
    if [ "$count" -gt 0 ]; then
        tooltip="$count active notification(s)"
    else
        tooltip="No active notifications"
    fi
fi

# Output JSON for waybar
echo "{\"text\":\"$count\",\"alt\":\"$icon\",\"tooltip\":\"$tooltip\",\"class\":\"$icon\"}"