#!/bin/bash

case "$1" in
    --waybar)
        # Get notification counts
        displayed=$(dunstctl count displayed 2>/dev/null || echo "0")
        waiting=$(dunstctl count waiting 2>/dev/null || echo "0")
        total=$((displayed + waiting))
        
        # Check if dunst is paused
        if dunstctl is-paused 2>/dev/null | grep -q "true"; then
            echo '{"text": " ⏸", "tooltip": "Notifications paused", "class": "paused"}'
        elif [[ $total -eq 0 ]]; then
            echo '{"text": " ", "tooltip": "No notifications", "class": "empty"}'
        else
            tooltip="$displayed displayed"
            [[ $waiting -gt 0 ]] && tooltip="$tooltip, $waiting waiting"
            echo "{\"text\": \" $total\", \"tooltip\": \"$tooltip\", \"class\": \"active\"}"
        fi
        ;;
    --history)
        # Show history in fuzzel
        if command -v fuzzel >/dev/null 2>&1; then
            dunstctl history | fuzzel --dmenu --prompt="Notifications: " --width=60
        else
            dunstctl history
        fi
        ;;
    *)
        echo "Usage: $0 [--waybar|--history]"
        ;;
esac