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
  programs.khal.enable = true;
  programs.khal.settings = {
    keybindings = {
      delete = "x";
      export = "ctrl e";
      external_edit = "e";
      duplicate = "d";
      save = "ctrl s";
    };
  };
}
