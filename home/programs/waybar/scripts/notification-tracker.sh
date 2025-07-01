#!/bin/bash

# Notification tracker script for waybar using dunst

get_notification_count() {
    # Get the number of notifications currently displayed
    dunstctl count displayed 2>/dev/null || echo "0"
}

get_dnd_status() {
    # Check if dunst is paused (do not disturb mode)
    if dunstctl is-paused 2>/dev/null | grep -q "true"; then
        echo "dnd"
    else
        echo "default"
    fi
}

case "$1" in
    --get)
        count=$(get_notification_count)
        status=$(get_dnd_status)
        
        if [[ "$status" == "dnd" ]]; then
            echo "{\"text\": \"DND\", \"tooltip\": \"Do Not Disturb enabled\", \"class\": \"dnd\", \"icon\": \"dnd\"}"
        elif [[ "$count" -gt 0 ]]; then
            echo "{\"text\": \"$count\", \"tooltip\": \"$count notifications\", \"class\": \"notifications\"}"
        else
            echo "{\"text\": \"0\", \"tooltip\": \"No notifications\", \"class\": \"empty\"}"
        fi
        ;;
    --toggle-dnd)
        dunstctl set-paused toggle
        ;;
    --clear)
        dunstctl close-all
        ;;
    *)
        get_notification_count
        ;;
esac