# Ollama on the 5090. This GPU is shared with the desktop/games, so the
# defaults here are tuned to *give VRAM back when idle* rather than to keep a
# model resident. Two escape hatches for long gaming sessions:
#   - passive: OLLAMA_KEEP_ALIVE unloads the model after you walk away
#   - hard:    `llm-down` stops the daemon entirely (see shellAliases below)
{ config, lib, pkgs, ... }:

{
  services.ollama = {
    enable = true;

    # CUDA build. Pulls the unfree CUDA userspace; allowUnfree is already on
    # for this host (the nvidia driver needs it). Replaces the old
    # `acceleration = "cuda"` option, which nixpkgs has since removed.
    package = pkgs.ollama-cuda;

    # Bind on all interfaces so both localhost tooling and the WG subnet can
    # reach it. The firewall below is what actually restricts access — only
    # wg0 gets the port, never the LAN/WAN.
    host = "0.0.0.0";
    port = 11434;

    environmentVariables = {
      # Keep-alive is just the "I walked away" cleanup here — the hard stop
      # for gaming is `llm-down`. So keep it generous enough that it never
      # unloads mid-work: 30 min of idle, then it frees the ~20 GB.
      OLLAMA_KEEP_ALIVE = "30m";

      # 32 GB is shared with the desktop — never stack two models in VRAM.
      OLLAMA_MAX_LOADED_MODELS = "1";

      # Smaller KV cache + faster attention on Blackwell. Safe for the modern
      # GGUF models you'd run here; drop it if a model misbehaves.
      OLLAMA_FLASH_ATTENTION = "1";
    };

    # Pre-pull models on activation. Left empty so you pull on demand
    # (`ollama pull qwen3-coder:30b`); add entries to bake them in instead.
    # loadModels = [ "qwen3-coder:30b" ];
  };

  # Expose the API *only* across the WireGuard tunnel (10.253.0.0/24), so
  # other hosts can point at the 5090 the way the pi points at dellbro00.
  # localhost still works regardless of this. Remove if you want it purely
  # local to this box.
  networking.firewall.interfaces."wg0".allowedTCPPorts = [ 11434 ];

  # One-word control over the whole daemon for long gaming sessions.
  environment.shellAliases = {
    llm-up = "systemctl start ollama.service";
    llm-down = "systemctl stop ollama.service";
    llm-ps = "ollama ps"; # what's resident + how much VRAM it's holding
  };
}
