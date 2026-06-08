#!/usr/bin/sh

cp /tmp/screenshot.png $HOME/Pictures/screenshots/screenshot_from_$(date +%Y-%m-%d_%H-%M-%S).png

PICOSHARE_BASE="https://picoshare.pimpchoko.com"
PICOSHARE_GUEST_LINK=$(cat /run/secrets/picoshare_token)

# Ask for confirmation before uploading
choice=$(printf "Yes\nNo" | fuzzel --dmenu -p "Upload screenshot to PicoShare? ")

if [ "$choice" = "Yes" ]; then
    # Upload to PicoShare via guest link; server returns plaintext URL when Accept != JSON
    url=$(curl -s -F "file=@/tmp/screenshot.png" "$PICOSHARE_BASE/api/guest/$PICOSHARE_GUEST_LINK" | tr -d '\r\n')

    if [ -n "$url" ] && [ "${url#http}" != "$url" ]; then
        # Copy URL to clipboard without newline
        printf "%s" "$url" | wl-copy

        # Send notification
        notify-send "Screenshot uploaded" "Link copied to clipboard: $url" -i camera-photo

        # Display the URL
        echo "$url"
    else
        notify-send "Screenshot upload failed" "Unable to upload to PicoShare" -i dialog-error
        echo "Upload failed: $url"
    fi
else
    notify-send "Screenshot saved" "Screenshot saved locally without uploading" -i camera-photo
    echo "Upload cancelled"
fi



