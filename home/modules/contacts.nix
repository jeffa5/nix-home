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
      name: value: {
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
        };
      }
    )
    accounts
  );

  accounts.contact.basePath = "contacts";

  services.vdirsyncer.enable = true;
  programs.vdirsyncer.enable = true;
  programs.khard.enable = true;
}
