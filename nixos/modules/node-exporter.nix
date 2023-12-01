{openFirewall}: {pkgs, ...}: let
  textFilesDir = "/var/lib/prometheus-node-exporter-text-files";
  ports = (import ./ports.nix).node-exporter;
in {
  services.prometheus.exporters.node = {
    enable = true;
    port = ports.private;
    enabledCollectors = ["systemd" "processes" "textfile"];
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

  services.nodeboard.services.node-exporter = {
    name = "Node exporter";
    url = "http://192.168.0.52:${toString ports.public}";
  };

  services.nginx.virtualHosts."node-exporter.local" = {
    # TODO: use DNS for this rather than relying on the ip
    serverName = "192.168.0.52:${toString ports.public}";
    listen = [
      {
        port = ports.public;
        addr = "0.0.0.0";
      }
    ];
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString ports.private}";
      proxyWebsockets = true;
    };
  };

  # TODO: specify default openings for nginx once we have DNS names
  networking.firewall.allowedTCPPorts = pkgs.lib.optionals openFirewall [ports.public];
}
