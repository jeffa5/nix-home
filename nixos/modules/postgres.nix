{config, ...}: let
  ports = (import ./ports.nix).postgres-exporter;
in {
  services.postgresql = {
    enable = true;
    identMap = ''
      # ArbitraryMapName systemUser         DBUser
      postgres      root               postgres
      postgres      postgres           postgres
      postgres      postgres-exporter  postgres
      # Let other names login as themselves
      superuser_map      /^(.*)$            \1
    '';
  };

  services.prometheus.exporters.postgres = {
    enable = true;
    listenAddress = "127.0.0.1";
    port = ports.private;
  };

  services.nginx.virtualHosts."Postgres exporter" = {
    serverName = "postgres-exporter.${config.networking.hostName}.home.jeffas.net";
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString ports.private}";
      proxyWebsockets = true;
    };
  };
}
