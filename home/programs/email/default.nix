{
  config,
  pkgs,
  theme,
  ...
}: {
  home.packages = with pkgs; [
    oama
    urlscan
  ];

  programs.mbsync.enable = true;
  programs.msmtp.enable = true;
  programs.vdirsyncer.enable = true;
  programs.khard.enable = true;
  programs.khal.enable = true;
  programs.aerc = {
    enable = true;
    extraConfig = {
      general = {
        # Allow accounts.conf to have permissions other than 600
        unsafe-accounts-conf = true;
        pgp-provider = "gpg";
      };
      compose = {
        file-picker-cmd = "fzf --multi --query=%s";
        header-layout = "To|From,Cc|Bcc,Subject";
        address-book-cmd = "khard email -a my_contacts --parsable --remove-first-line %s";
      };
      filters = {
        "text/plain" = "wrap -w 100 | colorize";
        "text/html" = "html | colorize";
        "message/delivery-status" = "colorize";
        "message/rfc822" = "colorize";
        "text/calendar" = "calendar";
        ".headers" = "colorize";
        "application/pdf" = "pdftotext - -l 10 -nopgbrk -q  - | fmt -w 100";
      };
      ui = {
        styleset-name = "stylix";
      };
    };
  };

  programs.notmuch = {
    enable = true;
    hooks = {
      preNew = "mbsync --all";
    };
  };

  accounts.email = {
    maildirBasePath = ".maildir";
    accounts = {
      "personal" = {
        address = "mike@michaelkim.net";
        userName = "mike@michaelkim.net";
        realName = "Michael Kim";
        passwordCommand = "${pkgs.pass}/bin/pass show email/mike@michaelkim.net | head -n1";
        imap.host = "imap.fastmail.com";
        smtp.host = "smtp.fastmail.com";
        mbsync = {
          enable = true;
          create = "both";
          expunge = "both";
          patterns = ["*"];
          extraConfig = {
            channel = {
              Sync = "All";
            };
            account = {
              Timeout = 120;
              PipelineDepth = 1;
            };
          };
        };
        aerc = {
          enable = true;
          extraAccounts = {
            signature-file = "/home/mike/.config/aerc/signature";
          };
        };
        msmtp.enable = true;
        notmuch.enable = true;
        primary = true;
      };

      "tsbot" = {
        address = "mike@tsbotfund.com";
        userName = "mike@tsbotfund.com";
        realName = "Michael Kim";
        passwordCommand = "${pkgs.pass}/bin/pass show email/mike@tsbotfund.com | head -n1";
        imap.host = "imap.fastmail.com";
        smtp.host = "smtp.fastmail.com";
        mbsync = {
          enable = true;
          create = "both";
          expunge = "both";
          patterns = ["*"];
          extraConfig = {
            channel = {
              Sync = "All";
            };
            account = {
              Timeout = 120;
              PipelineDepth = 1;
            };
          };
        };
        aerc = {
          enable = true;
          extraAccounts = {
            signature-file = "/home/mike/.config/aerc/tsbot_signature";
          };
        };
        msmtp.enable = true;
        notmuch.enable = true;
      };

      "notmuch" = {
        address = "mike@michaelkim.net";
        userName = "mike@michaelkim.net";
        realName = "Michael Kim";
        passwordCommand = "${pkgs.pass}/bin/pass show email/mike@michaelkim.net | head -n1";
        imap.host = "imap.fastmail.com";
        smtp.host = "smtp.fastmail.com";
        maildir.path = "~/.maildir";
        aerc = {
          enable = true;
          extraAccounts = {
            source = "notmuch://~/.maildir";
            outgoing = "msmtpq --read-envelope-from --read-recipients";
          };
        };
        msmtp.enable = true;
        notmuch.enable = true;
      };
    };
  };

  home.homeDirectory = "/home/mike";

  home.file = {
    ".config/aerc" = {
      source = ./aerc;
      recursive = true;
    };
    
    # Create Stylix-based styleset for aerc
    ".config/aerc/stylesets/stylix" = {
      text = ''
        #
        # aerc stylix styleset - auto-generated from Stylix colors
        #
        
        *.default=true
        
        title.reverse=true
        header.bold=true
        
        *error.bold=true
        error.fg=#${config.lib.stylix.colors.base08}
        warning.fg=#${config.lib.stylix.colors.base0A}
        success.fg=#${config.lib.stylix.colors.base0B}
        
        statusline*.default=true
        statusline_default.reverse=true
        statusline_error.reverse=true
        
        completion_pill.reverse=true
        
        border.reverse = true
        
        selector_focused.reverse=true
        selector_chooser.bold=true
        
        # Stylix color scheme
        
        *.selected.bg=#${config.lib.stylix.colors.base02}
        *.selected.fg=#${config.lib.stylix.colors.base07}
        
        msglist_marked.bg=#${config.lib.stylix.colors.base0D}
        msglist_flagged.fg=#${config.lib.stylix.colors.base0B}
        msglist_flagged.bold=true
        
        msglist_unread.fg=#${config.lib.stylix.colors.base0C}
        msglist_unread.selected.bg=#${config.lib.stylix.colors.base0D}
        
        statusline_default.fg=#${config.lib.stylix.colors.base03}
        statusline_error.fg=#${config.lib.stylix.colors.base08}
        
        tab.fg=#${config.lib.stylix.colors.base05}
        tab.bg=#${config.lib.stylix.colors.base01}
        tab.selected.bg=#${config.lib.stylix.colors.base0D}
        tab.selected.fg=#${config.lib.stylix.colors.base00}
        
        dirlist_unread.fg=#${config.lib.stylix.colors.base0D}
        dirlist_recent.fg=#${config.lib.stylix.colors.base0D}
      '';
    };

    ".config/vdirsyncer" = {
      source = ./vdirsyncer;
      recursive = true;
    };

    ".config/khal" = {
      source = ./khal;
      recursive = true;
    };

    ".config/khard" = {
      source = ./khard;
      recursive = true;
    };
  };

  # Define the systemd service
  systemd.user.services.notmuch-index = {
    Unit = {
      Description = "Run notmuch index";
    };
    Service = {
      Type = "oneshot";
      ExecStart = "${pkgs.notmuch}/bin/notmuch new"; # Command to run
      Restart = "on-failure"; # Optional: restart on failure
    };
    Install = {
      WantedBy = ["default.target"];
    };
  };

  # Define the systemd timer to run the service every 5 minutes
  systemd.user.timers.notmuch-index = {
    Unit = {
      Description = "Run notmuch index every 5 minutes";
    };
    Timer = {
      Unit = "notmuch-index.service";
      OnCalendar = "*:0/5"; # Every 5 minutes
      Persistent = true; # Ensures it runs if missed (e.g., after suspend)
    };
    Install = {
      WantedBy = ["timers.target"];
    };
  };

  systemd.user.services.vdirsyncer = {
    Unit = {
      Description = "Run vdirsyncer sync";
    };
    Service = {
      Type = "oneshot";
      ExecStart = "${pkgs.vdirsyncer}/bin/vdirsyncer sync"; # Command to run
      Restart = "on-failure"; # Optional: restart on failure
    };
    Install = {
      WantedBy = ["default.target"];
    };
  };

  systemd.user.timers.vdirsyncer = {
    Unit = {
      Description = "Run vdirsyncer sync every 5 minutes";
    };
    Timer = {
      Unit = "vdirsyncer.service";
      OnCalendar = "*:0/5"; # Every 5 minutes
      Persistent = true; # Ensures it runs if missed (e.g., after suspend)
    };
    Install = {
      WantedBy = ["timers.target"];
    };
  };
}
