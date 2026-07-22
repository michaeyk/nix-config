---
name: kdenlive
description: Work with Kdenlive through the Nix/Home Manager installed D-Ogi mcp-kdenlive D-Bus MCP server. Use for AI-assisted video editing: building timelines, importing media, transitions, markers, effects, previews, rendering, and Kdenlive project automation.
---

# Kdenlive MCP Skill

Use this skill when the user asks about Kdenlive video editing, timeline automation, `.kdenlive` projects, importing media, transitions, markers, effects, preview/QC, or rendering.

This machine is configured through Home Manager to use the developed D-Ogi Kdenlive MCP stack:

- `kdenlive-patched-dbus`: Kdenlive built from `D-Ogi/kdenlive` branch `feature/dbus-api-expansion`.
- `kdenlive-mcp-dbus`: wrapper for `D-Ogi/mcp-kdenlive` plus `D-Ogi/kdenlive-api`.
- MCP config: `~/kdenlive/.mcp.json`.

## Requirements

Kdenlive must be running, and it must be the patched D-Bus build installed by Home Manager. The MCP server talks to the session bus service exposed by that build.

## Preferred MCP workflow

When MCP tools are available, prefer composite tools first:

- `build_timeline` — import clips, sequence them, add transitions/audio/markers.
- `replace_scene` — replace one scene while preserving position/duration/transitions.
- `get_timeline_summary` — compact table of timeline state.
- `add_transitions_batch` — add dissolves between clips on a track.
- `render_video` — export final output.

Use atomic tools when needed: `get_project_info`, `save_project`, `load_project`, `import_media`, `import_media_glob`, `insert_clip`, `append_clips`, `move_clip`, `trim_clip`, `delete_clip`, `add_track`, `add_transition`, marker tools, effect tools, preview/QC tools, checkpoint tools, subtitles, proxy, selection, and playback.

## Safe editing rules

1. Confirm the patched Kdenlive is running before using MCP tools.
2. Start with `get_project_info` and `get_timeline_summary`.
3. Before risky edits, call `checkpoint_save(label)`.
4. After build/replace operations, visually verify with `render_frame`, `render_bin_frame`, `render_contact_sheet`, or `render_crop`.
5. Save with `save_project` after successful edits.

## Local checks

```bash
command -v kdenlive
command -v kdenlive-mcp-dbus
kdenlive-mcp-dbus --help || true
```

To see whether a running Kdenlive exposed the D-Bus service:

```bash
dbus-send --session --dest=org.freedesktop.DBus --print-reply \
  /org/freedesktop/DBus org.freedesktop.DBus.ListNames | grep org.kde.kdenlive
```

See `references/project-format.md` for repository and API reference pointers.
