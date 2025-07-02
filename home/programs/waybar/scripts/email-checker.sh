#!/bin/bash

# Email checker script for waybar using maildir

count_unread() {
    local maildir="$1"
    if [[ -d "$maildir/Inbox/cur" ]]; then
        find "$maildir/Inbox/cur" -type f | wc -l
    else
        echo 0
    fi
}

# Count unread emails in all maildir folders
personal_unread=$(count_unread ~/.maildir/personal)
tsbot_unread=$(count_unread ~/.maildir/tsbot)
total_unread=$((personal_unread + tsbot_unread))

# Format output for waybar
if [[ $total_unread -gt 0 ]]; then
    tooltip="$total_unread Inbox emails"
    if [[ $personal_unread -gt 0 && $tsbot_unread -gt 0 ]]; then
        tooltip="Personal: $personal_unread, TSBot: $tsbot_unread"
    elif [[ $personal_unread -gt 0 ]]; then
        tooltip="Personal: $personal_unread Inbox emails"
    elif [[ $tsbot_unread -gt 0 ]]; then
        tooltip="TSBot: $tsbot_unread Inbox emails"
    fi
    echo "{\"text\": \"$total_unread\", \"tooltip\": \"$tooltip\", \"class\": \"unread\"}"
else
    echo "{\"text\": \"0\", \"tooltip\": \"No Inbox emails\", \"class\": \"read\"}"
fi
