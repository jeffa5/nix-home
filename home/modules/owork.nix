{pkgs, ...}: {
  systemd.user.services.owork = {
    Unit.Description = "owork productivity timer";
    Install.WantedBy = ["graphical-session.target"];

    Service = {
      ExecStart = "${pkgs.owork}/bin/owork --long-break 25 --short-break 5 --work-duration 30 --work-sessions 4 --notify-script ${pkgs.sway-scripts.productivity-timer-notify}/bin/productivity-timer-notify";
      Restart = "on-failure";
    };
  };
}
