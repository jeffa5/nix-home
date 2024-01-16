{...}: let
  # ports = import ./ports.nix;
  port = 8086;
in {
  services.influxdb2 = {
    enable = true;
    settings = {
      # http-bind-address = ":${toString port}";
      reporting-disabled = true;
    };
  };

  # # TODO: get prometheus to scrape this
  # services.prometheus.exporters.influxdb = {
  #   enable = true;
  # };

  services.nginx.virtualHosts."Influxdb" = {
    serverName = "influxdb.home.jeffas.net";
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString port}";
      proxyWebsockets = true;
    };
  };
}
