{pkgs, ...}: {
  programs.git = {
    enable = true;
    userName = "Michael Kim";
    userEmail = "mike@michaelkim.net";

    diff-so-fancy.enable = true;

    extraConfig = {
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
      git.auto-local-bookmark= true;
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
