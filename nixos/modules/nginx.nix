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

  services.nodeboard.services.nginx-exporter = {
    name = "Nginx exporter";
    url = "http://192.168.0.52:${toString ports.public}";
  };

  services.nginx.virtualHosts."nginx-exporter.local" = {
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
  networking.firewall.allowedTCPPorts = [ports.public];
}
