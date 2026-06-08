#!/usr/bin/sh

# Read from stdin (Helix will always provide input via stdin)
text=$(cat)

PICOSHARE_BASE="https://picoshare.pimpchoko.com"
PICOSHARE_GUEST_LINK=$(cat /run/secrets/picoshare_token)

# Create temporary file for upload
tmpfile=$(mktemp /tmp/paste.XXXXXX.txt)
echo "$text" > "$tmpfile"

# Upload to PicoShare via guest link; server returns plaintext URL when Accept != JSON
url=$(curl -s -F "file=@$tmpfile" "$PICOSHARE_BASE/api/guest/$PICOSHARE_GUEST_LINK" | tr -d '\r\n')

# Clean up temp file
rm -f "$tmpfile"

if [ -n "$url" ] && [ "${url#http}" != "$url" ]; then
    # Output just the URL (this will replace the selection in Helix)
    printf "%s" "$url"

    # Copy to clipboard and send notification in background (don't block)
    (printf "%s" "$url" | wl-copy 2>/dev/null && \
     notify-send "Text uploaded" "Link copied to clipboard: $url" -i text-x-generic) &
else
    # Return original text if upload fails
    printf "%s" "$text"
    # Send error notification in background
    notify-send "Text upload failed" "Unable to upload to PicoShare" -i dialog-error &
    exit 1
fi
