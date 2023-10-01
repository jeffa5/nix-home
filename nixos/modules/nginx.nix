{...}: let
  ports = (import ./ports.nix).nginx-exporter;
in {
  services.nginx = {
    enable = true;
    recommendedTlsSettings = true;
    recommendedOptimisation = true;
    recommendedGzipSettings = true;
    recommendedProxySettings = true;
    statusPage = true;
  };

  services.prometheus.exporters.nginx = {
    enable = true;
    port = ports.private;
  };

  services.nginx.virtualHosts."nginx-exporter.local" = {
    # TODO: use DNS for this rather than relying on the ip
    # serverName = "...";
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
  networking.firewall.allowedTCPPorts = [ports.public];
}
