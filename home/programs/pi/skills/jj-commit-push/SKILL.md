---
name: jj-commit-push
description: Commit and push changes in repositories that use Jujutsu/jj instead of git. Use when the user asks to commit, push, land, or publish changes with jj, especially when the agent should generate the commit message and main must be moved before pushing.
---

# jj Commit and Push

Use `jj`, not `git`, for version-control operations.

## Preferred agent workflow

When the user asks to commit/push/publish/land changes:

1. Inspect the change enough to write a good message:
   ```bash
   jj status
   jj diff --stat
   jj diff
   ```
2. Generate a concise commit message yourself. Prefer an imperative one-line summary, with an optional body only when useful.
3. If the `jj_commit_push` tool is available, call it with the generated `message`. It will:
   - run `jj describe -m "<message>"`
   - run `jj bookmark move main --to @`
   - run `jj git push --bookmark main`
   - run `jj new main`
4. If the tool is unavailable, run the same commands manually:
   ```bash
   jj describe -m "<message>"
   jj bookmark move main --to @
   jj git push --bookmark main
   jj new main
   ```

## Safety notes

- Do not ask the user for a commit message unless they explicitly want to provide one or the diff is ambiguous.
- Do not run `git commit`, `git push`, or `git checkout` in jj repositories.
- Always move the `main` bookmark before pushing.
- Do not use `--allow-backwards` or force-like options unless the user explicitly asks.
- If `jj bookmark move main --to @` fails because the move is sideways/backwards, stop and ask the user how to proceed.
- If push fails due to remote/bookmark safety checks, suggest `jj git fetch` and ask before retrying.
