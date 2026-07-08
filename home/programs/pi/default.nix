{...}: {
  # Pi coding agent skills, symlinked into the global skills dir.
  # Using recursive = true so each file is linked individually, which keeps
  # the tree writable for adding more skills and preserves the executable bit.
  home.file.".pi/agent/skills/brave-search" = {
    source = ./skills/brave-search;
    recursive = true;
  };
}
