{
  pkgs,
  lib,
  ...
}: let
  # the same accounts email.nix builds msmtp and mbsync from
  accounts =
    lib.optionalAttrs
    (builtins.pathExists ./email-accounts.nix)
    (import ./email-accounts.nix);
  msmtp = lib.getExe pkgs.msmtp;
  address = value: "Andrew Jeffery <${value.address}>";
in {
  programs.rical = {
    # the queue sends; rical-mail only has to write into it
    mailQueue = {
      enable = true;
      # one sending command per sender; a sender without one fails rather than going out another way
      sendFrom =
        lib.mapAttrsToList (name: value: {
          from = value.address;
          command = "${msmtp} -a ${name} -- $RICAL_MAIL_QUEUE_RECIPIENTS";
        })
        accounts;
      packages = [pkgs.msmtp];
    };

    # reads the Maildirs mbsync keeps in sync; vdir, queue and contacts come from the rest of programs.rical
    mail = {
      enable = true;
      mail = "~/mail";
      me = lib.mapAttrsToList (_: address) accounts;
      accounts = lib.mapAttrs (_: value: [(address value)]) accounts;
      settings.search = "mu";
    };
  };
}
