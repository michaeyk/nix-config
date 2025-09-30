#!/usr/bin/sh

# Read from stdin (Helix will always provide input via stdin)
text=$(cat)

# Create temporary file for upload
tmpfile=$(mktemp /tmp/paste.XXXXXX.txt)
echo "$text" > "$tmpfile"

# Upload to 0x0.st and capture the URL
url=$(curl -s -F"file=@$tmpfile" https://0x0.st)

# Clean up temp file
rm -f "$tmpfile"

if [ -n "$url" ]; then
    # Output just the URL (this will replace the selection in Helix)
    printf "%s" "$url"

    # Copy to clipboard and send notification in background (don't block)
    (printf "%s" "$url" | wl-copy 2>/dev/null && \
     notify-send "Text uploaded" "Link copied to clipboard: $url" -i text-x-generic) &
else
    # Return original text if upload fails
    printf "%s" "$text"
    # Send error notification in background
    notify-send "Text upload failed" "Unable to upload to 0x0.st" -i dialog-error &
    exit 1
fi