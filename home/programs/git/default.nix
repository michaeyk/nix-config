{pkgs, ...}: {
  programs.git = {
    enable = true;
    signing.format = "openpgp";
    settings = {
      user = {
        name = "Michael Kim";
        email = "mike@michaelkim.net";
      };
      init.defaultBranch = "main";
      advice.addEmbeddedRepo = false;
      core = {
        editor = "${pkgs.helix}/bin/hx";
      };
      commit = {
        template = "~/.gitmessage";
      };
    };
  };

  programs.diff-so-fancy = {
    enable = true;
    enableGitIntegration = true;
  };

  programs.jujutsu = {
    enable = true;
    settings = {
      user = {
        email = "mike@michaelkim.net";
        name = "Michael Kim";
      };
      ui = {
        default-command = "log";
      };
      remotes.origin.auto-track-bookmarks = "*";
      aliases.all = ["log" "-r" "all()" ];
    };
   };

  programs.lazygit.enable = true;

  home.file = {
    ".gitmessage" = {
      source = ./gitmessage;
    };
  };
}
