{pkgs, ...}: let
  s = "${pkgs.libsecret}/bin/secret-tool";
  stl = ["${s}" "lookup"];
  accounts =
    pkgs.lib.optionalAttrs
    (builtins.pathExists ./contact-accounts.nix)
    (import ./contact-accounts.nix);
in {
  accounts.contact.accounts = (
    pkgs.lib.attrsets.mapAttrs (
      _name: value: {
        local = {
          type = "filesystem";
          fileExt = ".vcf";
        };
        remote = {
          passwordCommand = stl ++ ["type" "contact" "account" value.address];
          type = "carddav";
          url = value.url;
          userName = value.userName;
        };
        khard.enable = true;
        vdirsyncer = {
          enable = true;
          collections = ["from a" "from b"];
          conflictResolution = "remote wins";
        };
        thunderbird.enable = true;
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

  accounts.contact.basePath = "contacts";

  services.vdirsyncer.enable = true;
  programs.vdirsyncer.enable = true;

  programs.pimsync.enable = true;

  programs.khard.enable = true;
}
