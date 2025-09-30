#!/usr/bin/sh

cp /tmp/screenshot.png $HOME/Pictures/screenshots/screenshot_from_$(date +%Y-%m-%d_%H-%M-%S).png

# Upload to 0x0.st and capture the URL
url=$(curl -s -F'file=@/tmp/screenshot.png' https://0x0.st)

if [ -n "$url" ]; then
    # Copy URL to clipboard without newline
    printf "%s" "$url" | wl-copy

    # Send notification
    notify-send "Screenshot uploaded" "Link copied to clipboard: $url" -i camera-photo

    # Display the URL
    echo "$url"
else
    notify-send "Screenshot upload failed" "Unable to upload to 0x0.st" -i dialog-error
    echo "Upload failed"
fi



