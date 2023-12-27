{config, ...}: let
  private_port = 9090;
  ports = import ./ports.nix;
  selfHost = config.networking.hostName;
  serverName = "prometheus.home.jeffas.net";
in {
  services.prometheus = {
    enable = true;
    port = private_port;

    scrapeConfigs = [
      {
        job_name = "prometheus";
        static_configs = [
          # self scrape
          {targets = ["${serverName}"];}
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
          {targets = ["grafana.home.jeffas.net"];}
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
      {
        job_name = "dnsmasq";
        static_configs = [
          {targets = ["${selfHost}:${toString config.services.prometheus.exporters.dnsmasq.port}"];}
        ];
      }
    ];

    retentionTime = "5y";

    globalConfig = {
      scrape_interval = "15s";
    };
  };

  services.nodeboard.services.prometheus = {
    name = "Prometheus";
    url = "http://${serverName}";
    useFavicon = true;
  };

  services.nginx.virtualHosts."prometheus.local" = {
    inherit serverName;
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString private_port}";
      proxyWebsockets = true;
    };
  };
}
