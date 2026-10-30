{
  config,
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
  queueConfig =
    lib.concatStringsSep "\n" (
      # one sending command per sender; a sender without one fails rather than going out another way
      lib.mapAttrsToList (
        name: value: "send-from ${value.address} = ${msmtp} -a ${name} -- $RICAL_MAIL_QUEUE_RECIPIENTS"
      )
      accounts
    )
    + "\n";
in {
  # rical-mail reads the Maildirs mbsync keeps in sync; the queue sends
  xdg.configFile."rical-mail/config".text = ''
    mail = ~/mail
    me = ${lib.concatStringsSep ", " (lib.mapAttrsToList (_: v: v.address) accounts)}
    contacts = ~/contacts/nextcloud
    vdir = ~/calendar/nextcloud
    sync = ${lib.getExe' pkgs.isync "mbsync"} -a
    search = mu
  '';

  xdg.configFile."rical-mail-queue/config".text = queueConfig;

  # the queue's worker; rical-mail only has to write into the queue
  systemd.user.services.rical-mail-queue = {
    Unit.Description = "rical mail queue";
    Service = {
      ExecStart = "${config.programs.rical.package}/bin/rical-mail-queue run";
      Restart = "on-failure";
    };
    Install.WantedBy = ["default.target"];
  };
}
