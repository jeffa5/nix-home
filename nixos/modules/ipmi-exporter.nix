{pkgs, ...}: let
  textFilesDir = "/var/lib/prometheus-node-exporter-text-files";
  ipmimetrics = pkgs.writeShellScript "ipmi-metrics" ''
    set -euo pipefail

    {
      echo "# HELP ipmi_temperature_celsius Temperature reading from IPMI sensor"
      echo "# TYPE ipmi_temperature_celsius gauge"
      ${pkgs.ipmitool}/bin/ipmitool sdr type Temperature 2>/dev/null \
        | grep -v ' ns ' \
        | while IFS='|' read -r name _id _status _lun value; do
            sensor=$(echo "$name" | xargs | sed 's/ /_/g;s/-/_/g' | tr '[:upper:]' '[:lower:]')
            celsius=$(echo "$value" | grep -o '[0-9]\+' | head -1)
            [ -n "$celsius" ] && echo "ipmi_temperature_celsius{sensor=\"$sensor\"} $celsius"
          done

      echo "# HELP ipmi_fan_speed_percent Fan speed from IPMI sensor"
      echo "# TYPE ipmi_fan_speed_percent gauge"
      ${pkgs.ipmitool}/bin/ipmitool sdr type Fan 2>/dev/null \
        | grep -v ' ns ' \
        | while IFS='|' read -r name _id _status _lun value; do
            sensor=$(echo "$name" | xargs | sed 's/ /_/g;s/-/_/g' | tr '[:upper:]' '[:lower:]')
            pct=$(echo "$value" | grep -o '[0-9.]\+' | head -1)
            [ -n "$pct" ] && echo "ipmi_fan_speed_percent{sensor=\"$sensor\"} $pct"
          done
    } > ${textFilesDir}/ipmi.prom.next
    mv ${textFilesDir}/ipmi.prom.next ${textFilesDir}/ipmi.prom
  '';
in {
  environment.systemPackages = [pkgs.ipmitool];

  users.groups.ipmi = {};

  # Allow the ipmi group to open /dev/ipmi0 for in-band BMC access
  services.udev.extraRules = ''
    KERNEL=="ipmi0", GROUP="ipmi", MODE="0660"
  '';

  systemd.services.ipmi-metrics = {
    description = "Collect IPMI sensor metrics for node-exporter textfile collector";
    serviceConfig = {
      Type = "oneshot";
      User = "root";
      ExecStart = ipmimetrics;
    };
  };

  systemd.timers.ipmi-metrics = {
    wantedBy = ["timers.target"];
    timerConfig = {
      OnBootSec = "1min";
      OnUnitActiveSec = "1min";
      Unit = "ipmi-metrics.service";
    };
  };
}
