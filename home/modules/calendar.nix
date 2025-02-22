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
        primary = true;
        primaryCollection = value.primaryCollection;
        remote = {
          passwordCommand = stl ++ ["type" "calendar" "account" value.address];
          type = "caldav";
          url = value.url;
          userName = value.userName;
        };
        vdirsyncer = {
          enable = true;
          collections = ["from a" "from b"];
        };
      }
    )
    accounts
  );

  accounts.calendar.basePath = "calendar";

  services.vdirsyncer.enable = true;
  programs.vdirsyncer.enable = true;
  programs.khal = {
    enable = true;
    package =
      pkgs.khal.overrideAttrs
      (_finalAttrs: _previousAttrs: {
        src = pkgs.fetchFromGitHub {
          owner = "jeffa5";
          repo = "khal";
          rev = "35665e6c5a942621d686c55e809c9805d3c48c73"; # branch "myfeatures"
          sha256 = "sha256-MsNtyFAoNhqgD2cr1+KSD9U8JFHBklrSiTH1jh79sF8=";
        };
      });
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
        external_edit = "e";
        duplicate = "d";
        save = "ctrl s";
      };
    };
  };
}
