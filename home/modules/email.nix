{pkgs, ...}: let
  s = "${pkgs.libsecret}/bin/secret-tool";
  stl = "${s} lookup";
  mbsync = "${pkgs.isync}/bin/mbsync";
  # optionally use config from email-accounts.nix if it exists, otherwise no email accounts will be set up
  accounts =
    pkgs.lib.optionalAttrs
    (builtins.pathExists ./email-accounts.nix)
    (import ./email-accounts.nix);
  search =
    pkgs.lib.optionalAttrs
    (builtins.pathExists ./email-accounts.nix)
    {
      search = {
        maildir.path = "search";
        realName = "Search Index";
        address = "search@local";
        aerc.enable = true;
        aerc.extraAccounts = {
          source = "maildir://~/mail/search";
        };
        aerc.extraConfig = {
          ui = {
            index-columns = "flags>4,date<*,to<30,name<30,subject<*";
            column-to = "{{(index .To 0).Address}}";
          };
        };
        # himalaya.enable = true;
      };
    };
in {
  accounts.email.accounts =
    (pkgs.lib.attrsets.mapAttrs (name: value: {
        inherit (value) address flavor imap smtp primary;
        userName = value.address;

        # create with `secret-tool store type email account ${value.address}`
        passwordCommand = "${stl} type email account ${value.address}";

        aerc.enable = true;
        aerc.extraAccounts = {
          source = "maildir://~/mail/${name}";
          check-mail-cmd = "${mbsync} ${name}";
        };
        himalaya = {
          enable = true;
        };
        imapnotify = {
          enable = true;
          boxes = ["Inbox"];
          onNotify = "${mbsync} ${name}";
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
        msmtp.enable = true;
        mu.enable = true;

        realName = "Andrew Jeffery";

        thunderbird.enable = true;
      })
      accounts)
    // search;

  accounts.email.maildirBasePath = "mail";

  services.imapnotify.enable = true;
  programs.himalaya.enable = true;
  programs.mu.enable = true;
  programs.msmtp.enable = true;
}
