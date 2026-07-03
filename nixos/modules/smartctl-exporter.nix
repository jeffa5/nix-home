{config, ...}: let
  ports = (import ./ports.nix).smartctl-exporter;
in {
  services.prometheus.exporters.smartctl = {
    enable = true;
    port = ports.private;
    listenAddress = "127.0.0.1";
  };

  services.nginx.virtualHosts."Smartctl exporter" = {
    serverName = "smartctl-exporter.${config.networking.hostName}.home.jeffas.net";
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString ports.private}";
      proxyWebsockets = true;
    };
  };
}
