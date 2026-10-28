{pkgs, ...}: let
  s = "${pkgs.libsecret}/bin/secret-tool";
  stl = ["${s}" "lookup"];
  accounts =
    pkgs.lib.optionalAttrs
    (builtins.pathExists ./calendar-accounts.nix)
    (import ./calendar-accounts.nix);
in {
  accounts.calendar.accounts = (
    pkgs.lib.attrsets.mapAttrs (
      _name: value: {
        khal = {
          enable = true;
          color = value.color;
          type = "discover";
        };
        local = {
          fileExt = ".ics";
          type = "filesystem";
        };
        primary = value.primary;
        primaryCollection = value.primaryCollection;
        remote = {
          passwordCommand = stl ++ ["type" "calendar" "account" value.address];
          type = "caldav";
          url = value.url;
          userName = value.userName;
        };
        vdirsyncer = {
          enable = true;
          collections = value.vdirsyncerCollections or ["from a" "from b"];
          conflictResolution = "remote wins";
        };
        pimsync = {
          enable = true;
          extraPairDirectives = [
            {
              name = "collections";
              params = ["all"];
            }
            {
              name = "conflict_resolution";
              params = ["keep" "b"]; # keep server version
            }
          ];
        };
      }
    )
    accounts
  );

  accounts.calendar.basePath = "calendar";

  services.vdirsyncer.enable = true;
  programs.vdirsyncer.enable = true;

  programs.pimsync.enable = true;

  programs.khal = {
    enable = true;
    locale = {
      timeformat = "%H:%M";
      weeknumbers = "left";
    };
    settings = {
      default = {
        default_organizer = "andrew@jeffas.net";
      };
      keybindings = {
        delete = "x";
        export = "ctrl e";
        duplicate = "d";
        save = "ctrl s";
      };
    };
  };
  programs.rical = {
    enable = true;
    vdir = "~/calendar/nextcloud";
    calendar = "personal";
    openCalendarFiles = true;
    openContactFiles = true;
    settings = {
      me = "andrew@jeffas.net";
      contacts = "~/contacts/nextcloud";
      zones = "America/Los_Angeles,America/Chicago,Europe/London";
    };
  };
  xdg.configFile."rical/contacts/config".text = ''
    contacts = ~/contacts/nextcloud
  '';
  programs.todoman = {
    enable = true;
    glob = "nextcloud/*";
    extraConfig = ''
      default_list = "personal"
    '';
  };
}
