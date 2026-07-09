---
name: plan-mode
description: Produce a detailed implementation plan before writing any code. Use when the user asks to plan, design an approach, or says "plan mode" before a complex change.
---

# Plan Mode

When this skill is active, do NOT modify the codebase. Work read-only.

## Steps

1. Use `read`, `bash` (for `rg`/`ls`/`grep`), and inspection only. Do not use `write` or `edit`.
2. Investigate the relevant files and current behavior.
3. Produce a plan with:
   - **Goal** — one sentence.
   - **Affected files** — bullet list with why each changes.
   - **Steps** — ordered, concrete edits.
   - **Risks / open questions** — anything ambiguous.
4. End by asking: "Approve this plan? Reply 'go' to implement."
5. Only start editing after the user approves.
