{config, ...}: let
  public_port = 9000;
  private_port = 9090;
  ports = import ./ports.nix;
  selfHost = config.networking.hostName;
in {
  services.prometheus = {
    enable = true;
    port = private_port;

    scrapeConfigs = [
      {
        job_name = "prometheus";
        static_configs = [
          # self scrape
          {targets = ["${selfHost}:${toString public_port}"];}
        ];
      }
      {
        job_name = "loki";
        static_configs = [
          {targets = ["${selfHost}:${toString ports.loki.public}"];}
        ];
      }
      {
        job_name = "grafana";
        static_configs = [
          {targets = ["${selfHost}:${toString ports.grafana.public}"];}
        ];
      }
      {
        job_name = "node";
        static_configs = [
          # this pi (rpi1)
          {targets = ["${selfHost}:${toString ports.node-exporter.public}"];}
          # rpi2
          {targets = ["rpi2:${toString ports.node-exporter.public}"];}
          # xps15, not running nginx
          {targets = ["xps15:${toString ports.node-exporter.private}"];}
          # carbide, not running nginx
          {targets = ["carbide:${toString ports.node-exporter.private}"];}
        ];
      }
      {
        job_name = "promtail";
        static_configs = [
          # this pi (rpi1)
          {targets = ["${selfHost}:${toString ports.promtail.public}"];}
          # rpi2
          {targets = ["rpi2:${toString ports.promtail.public}"];}
          # xps15, not running nginx
          {targets = ["xps15:${toString ports.promtail.private}"];}
          # carbide, not running nginx
          {targets = ["carbide:${toString ports.promtail.private}"];}
        ];
      }
      {
        job_name = "nginx";
        static_configs = [
          # this pi (rpi1)
          {targets = ["${selfHost}:${toString ports.nginx-exporter.public}"];}
          # rpi2
          {targets = ["rpi2:${toString ports.nginx-exporter.public}"];}
        ];
      }
    ];

    globalConfig = {
      scrape_interval = "15s";
    };
  };

  services.nodeboard.services.prometheus = {
    name = "Prometheus";
    url = "http://rpi1:${toString public_port}";
    useFavicon = true;
  };

  services.nginx.virtualHosts."prometheus.local" = {
    serverName = "${config.networking.hostName}:${toString public_port}";
    listen = [
      {
        port = public_port;
        addr = "0.0.0.0";
      }
    ];
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString private_port}";
      proxyWebsockets = true;
    };
  };

  # TODO: specify default openings for nginx once we have DNS names
  networking.firewall.allowedTCPPorts = [public_port];
}
