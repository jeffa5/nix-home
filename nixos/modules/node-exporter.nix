{...}: let
  textFilesDir = "/var/lib/prometheus-node-exporter-text-files";
in {
  services.prometheus.exporters.node = {
    enable = true;
    enabledCollectors = ["systemd" "textfile"];
    extraFlags = [
      "--collector.textfile.directory=${textFilesDir}"
    ];
  };

  # https://grahamc.com/blog/nixos-system-version-prometheus/
  # populate the textfile directory with the current system version on every boot and deployment
  system.activationScripts.node-exporter-system-version = ''
    mkdir -pm 0775 ${textFilesDir}
    (
      cd ${textFilesDir}
      (
        echo -n "system_version ";
        readlink /nix/var/nix/profiles/system | cut -d- -f2
      ) > system-version.prom.next
      mv system-version.prom.next system-version.prom
    )
  '';
}
