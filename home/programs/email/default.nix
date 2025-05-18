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
  programs.aerc = {
    enable = true;
    extraConfig = {
      # Allow accounts.conf to have permissions other than 600
      general.unsafe-accounts-conf = true;
      compose = {
        file-picker-cmd = "fzf --multi --query=%s";
        header-layout = "To|From,Cc|Bcc,Subject";
        # address-book-cmd = "carddav-query -S personal -u mike %s";
        address-book-cmd = "khard email -a personal --parsable --remove-first-line %s";
      };
      filters = {
        "text/plain" = "wrap -w 100 | colorize";
        "text/html" = "html | colorize";
        # "text/html" = "pandoc -f html -t plain";
        "message/delivery-status" = "colorize";
        "message/rfc822" = "colorize";
        "text/calendar" = "calendar";
        ".headers" = "colorize";
        "application/pdf" = "pdftotext - -l 10 -nopgbrk -q  - | fmt -w 100";
      };
      ui = {
        styleset-name = "dracula";
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
            # carddav-source = "https://nextcloud.michaelkim.net/remote.php/dav/addressbooks/users/mike/contacts/";
            # carddav-source-cred-cmd = "pass show hosting/vdirsyncer | head -n1";
            signature-file = "/home/mike/.signature";
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
            signature-file = "/home/mike/.tsbot_signature";
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

    ".config/vdirsyncer" = {
      source = ./vdirsyncer;
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
}
