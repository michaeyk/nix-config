#!/bin/bash

# File to store unread count
UNREAD_FILE="/tmp/dunst_unread_count"

# Initialize count file if it doesn't exist
if [ ! -f "$UNREAD_FILE" ]; then
    echo "0" > "$UNREAD_FILE"
fi

case "$1" in
    --increment)
        # Called when new notification arrives
        current=$(cat "$UNREAD_FILE" 2>/dev/null || echo "0")
        echo $((current + 1)) > "$UNREAD_FILE"
        ;;
    --decrement)
        # Called when notification is clicked/dismissed
        current=$(cat "$UNREAD_FILE" 2>/dev/null || echo "0")
        if [ "$current" -gt 0 ]; then
            echo $((current - 1)) > "$UNREAD_FILE"
        fi
        ;;
    --clear)
        # Clear all unread notifications
        echo "0" > "$UNREAD_FILE"
        ;;
    --get)
        # Get current count for waybar
        count=$(cat "$UNREAD_FILE" 2>/dev/null || echo "0")
        paused=$(dunstctl is-paused)
        
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
        
        echo "{\"text\":\"$count\",\"alt\":\"$icon\",\"tooltip\":\"$tooltip\",\"class\":\"$icon\"}"
        ;;
    *)
        echo "Usage: $0 [--increment|--decrement|--clear|--get]"
        ;;
esac