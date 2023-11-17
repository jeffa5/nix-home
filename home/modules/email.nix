{pkgs, ...}: let
  s = "${pkgs.libsecret}/bin/secret-tool";
  stl = "${s} lookup";
  # optionally use config from email-accounts.nix if it exists, otherwise no email accounts will be set up
  accounts =
    pkgs.lib.optionalAttrs
    (builtins.pathExists ./email-accounts.nix)
    (import ./email-accounts.nix);
in {
  accounts.email.accounts =
    pkgs.lib.attrsets.mapAttrs (name: value: {
      inherit (value) address flavor imap smtp primary;
      userName = value.address;

      # create with `secret-tool store type email account ${value.address}`
      passwordCommand = "${stl} type email account ${value.address}";

      aerc.enable = true;
      aerc.extraAccounts = {
        source = "maildir://~/mail/${name}";
      };
      himalaya = {
        enable = true;
      };
      imapnotify = {
        enable = true;
        boxes = ["Inbox"];
        onNotify = "${pkgs.isync}/bin/mbsync ${name}";
      };
      maildir = {
        path = "${name}";
      };
      mbsync = {
        enable = true;
        create = "both";
        expunge = "both";
        remove = "both";
      };
      mu.enable = true;

      realName = "Andrew Jeffery";

      thunderbird.enable = true;
    })
    accounts;

  accounts.email.maildirBasePath = "mail";

  services.imapnotify.enable = false;
  programs.himalaya.enable = true;
  programs.mu.enable = true;
}
