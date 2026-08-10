{pkgs, ...}: {
  services.btrfs.autoScrub.enable = true;

  # Periodically reclaim unallocated space so the metadata chunk can grow;
  # otherwise it can fill up and cause ENOSPC even with data space free.
  systemd.services.btrfs-balance = {
    description = "Reclaim unallocated space on btrfs filesystems";
    script = ''
      set -u
      ${pkgs.util-linux}/bin/findmnt -t btrfs -n -o TARGET,UUID \
        | ${pkgs.gawk}/bin/awk '!seen[$2]++ {print $1}' \
        | while read -r mountpoint; do
            ${pkgs.btrfs-progs}/bin/btrfs balance start -dusage=50 -musage=50 "$mountpoint" || true
          done
    '';
    serviceConfig = {
      Type = "oneshot";
      Nice = 19;
      IOSchedulingClass = "idle";
    };
  };

  systemd.timers.btrfs-balance = {
    description = "Periodic btrfs balance";
    wantedBy = ["timers.target"];
    timerConfig = {
      OnCalendar = "monthly";
      Persistent = true;
      RandomizedDelaySec = "1h";
    };
  };
}
