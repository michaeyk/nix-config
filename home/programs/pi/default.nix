{...}: {
  # Pi coding agent enhancements, symlinked into the global agent dir
  # (~/.pi/agent). Using recursive = true so each file is linked
  # individually: it keeps the parent dirs writable (so pi can still add
  # its own agents/prompts/skills at runtime) and preserves the
  # executable bit on scripts.
  #
  # NOTE: mutable runtime state (auth.json, settings.json, models.json) is
  # deliberately NOT managed here, since pi writes to those files.
  home.file = {
    ".pi/agent/agents" = {
      source = ./agents;
      recursive = true;
    };
    ".pi/agent/prompts" = {
      source = ./prompts;
      recursive = true;
    };
    ".pi/agent/skills/brave-search" = {
      source = ./skills/brave-search;
      recursive = true;
    };
    ".pi/agent/skills/jj-commit-push" = {
      source = ./skills/jj-commit-push;
      recursive = true;
    };
    ".pi/agent/skills/plan-mode.md".source = ./skills/plan-mode.md;
    ".pi/agent/settings.json".source = ./settings.json;
    ".pi/agent/models.json".source = ./models.json;
  };
}
