#!/usr/bin/env bash
# Fetch weather via wttrbar with a hard timeout so a stalled wttr.in
# connection can never permanently wedge Waybar's module thread.
# Caches the last good result so a timed-out cycle doesn't blank the widget.

cache="${XDG_RUNTIME_DIR:-/tmp}/waybar-weather.json"

out="$(timeout 15 wttrbar --fahrenheit 2>/dev/null)"

if [ -n "$out" ]; then
  printf '%s' "$out" > "$cache"
  printf '%s' "$out"
elif [ -f "$cache" ]; then
  cat "$cache"
else
  printf '{"text":"","tooltip":"weather unavailable"}'
fi
