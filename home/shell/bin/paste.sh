#!/usr/bin/sh

# Read from clipboard or stdin
if [ -t 0 ]; then
    # No stdin, try to get from clipboard
    text=$(wl-paste 2>/dev/null)
    if [ -z "$text" ]; then
        notify-send "Paste upload failed" "No text in clipboard" -i dialog-error
        exit 1
    fi
else
    # Read from stdin
    text=$(cat)
fi

# Create temporary file for upload
tmpfile=$(mktemp /tmp/paste.XXXXXX.txt)
echo "$text" > "$tmpfile"

# Upload to 0x0.st and capture the URL
url=$(curl -s -F"file=@$tmpfile" https://0x0.st)

# Clean up temp file
rm -f "$tmpfile"

if [ -n "$url" ]; then
    # Copy URL to clipboard without newline
    printf "%s" "$url" | wl-copy

    # Send notification
    notify-send "Text uploaded" "Link copied to clipboard: $url" -i text-x-generic

    # Display the URL
    echo "$url"
else
    notify-send "Text upload failed" "Unable to upload to 0x0.st" -i dialog-error
    echo "Upload failed"
    exit 1
fi