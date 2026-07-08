#!/usr/bin/env bash
# Brave Search API helper.
# Usage: ./search.sh "query" [--count N] [--news] [--raw]
set -euo pipefail

if [[ -z "${BRAVE_API_KEY:-}" ]]; then
  if [[ -r /run/secrets/BRAVE_API_KEY ]]; then
    BRAVE_API_KEY="$(cat /run/secrets/BRAVE_API_KEY)"
  else
    echo "error: BRAVE_API_KEY not set and /run/secrets/BRAVE_API_KEY unreadable" >&2
    exit 1
  fi
fi

query=""
count=5
endpoint="web"
raw=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --count) count="$2"; shift 2 ;;
    --news)  endpoint="news"; shift ;;
    --raw)   raw=1; shift ;;
    -h|--help)
      echo "Usage: search.sh \"query\" [--count N] [--news] [--raw]"; exit 0 ;;
    *) query="${query:+$query }$1"; shift ;;
  esac
done

if [[ -z "$query" ]]; then
  echo "error: no query provided" >&2
  exit 1
fi

resp="$(curl -s --max-time 20 --get \
  -H "Accept: application/json" \
  -H "X-Subscription-Token: $BRAVE_API_KEY" \
  --data-urlencode "q=$query" \
  --data-urlencode "count=$count" \
  "https://api.search.brave.com/res/v1/${endpoint}/search")"

if [[ "$raw" == "1" ]]; then
  echo "$resp"
  exit 0
fi

echo "$resp" | jq -r '
  (.web.results // .results // [])
  | to_entries[]
  | "[\(.key + 1)] \(.value.title)\n    \(.value.url)\n    \(.value.description // "" | gsub("<[^>]*>";""))\n"
'
