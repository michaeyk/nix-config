---
name: brave-search
description: Web and news search via the Brave Search API. Use to look up current documentation, facts, package versions, error messages, or any information that may be newer than the model's knowledge.
---

# Brave Search

Query the Brave Search API from the command line. The API key is read from the
`BRAVE_API_KEY` environment variable, falling back to `/run/secrets/BRAVE_API_KEY`
(sops-nix secret), so no extra setup is required on this machine.

## Usage

```bash
./search.sh "your query"              # Top 5 web results (title, url, snippet)
./search.sh "your query" --count 10   # More results
./search.sh "breaking topic" --news   # News endpoint
./search.sh "your query" --raw        # Full JSON response
```

Run from the skill directory, or with an absolute path:

```bash
~/.pi/agent/skills/brave-search/search.sh "nixos sops-nix env var"
```

## Notes

- Requires `curl` and `jq` (both present on this system).
- Results are trimmed to title / URL / description. Use `--raw` when you need
  more fields (age, thumbnails, deep results, etc.).
- To read the full content of a result page, fetch it directly, e.g.
  `curl -sL <url> | pandoc -f html -t plain` or similar.
