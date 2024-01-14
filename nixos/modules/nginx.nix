{config, ...}: let
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
    url = "http://nginx-exporter.${config.networking.hostName}.home.jeffas.net";
  };

  services.nginx.virtualHosts."nginx-exporter.local" = {
    serverName = "nginx-exporter.${config.networking.hostName}.home.jeffas.net";
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString ports.private}";
      proxyWebsockets = true;
    };
  };
}
