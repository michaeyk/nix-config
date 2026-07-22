# Kdenlive MCP reference

Home Manager packages:

- `kdenlive-patched-dbus`: patched Kdenlive from `D-Ogi/kdenlive`, commit `fb0c86d4e6f6197a13e9b84aa45ef3da82a5f38a` (`feature/dbus-api-expansion`).
- `kdenlive-mcp-dbus`: wrapper around `D-Ogi/mcp-kdenlive`, commit `afe585143f631fa00f62a1d22207d85df06a0d74`.
- `kdenlive-api`: `D-Ogi/kdenlive-api`, commit `d1f87baa127d2950d89b923f7a0206defb124073`.

Important upstream files:

- `mcp-kdenlive/README.md` — server requirements and tool overview.
- `mcp-kdenlive/mcp_kdenlive/server.py` — full tool registration list and agent instructions.
- `mcp-kdenlive/mcp_kdenlive/resources.py` — MCP cookbook (`kdenlive://cookbook`).
- `kdenlive-api/docs/kdenlive-api.md` — Python API reference.

Core workflow:

1. `get_project_info`
2. `get_timeline_summary`
3. `checkpoint_save`
4. composite edit tool (`build_timeline`, `replace_scene`, etc.)
5. preview/QC (`render_frame`, `render_contact_sheet`, `render_crop`)
6. `save_project`
