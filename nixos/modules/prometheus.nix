{config, ...}: let
  private_port = 9090;
  ports = import ./ports.nix;
  homeNet = "home.jeffas.net";
  rpi1 = "rpi1.${homeNet}";
  rpi2 = "rpi2.${homeNet}";
  xps15 = "xps15.${homeNet}";
  carbide = "carbide.${homeNet}";
  serverName = "prometheus.${homeNet}";
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
          {targets = ["loki.home.jeffas.net"];}
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
          {targets = ["node-exporter.${rpi1}"];}
          # rpi2
          {targets = ["node-exporter.${rpi2}"];}
          # xps15, not running nginx
          {targets = ["${xps15}:${toString ports.node-exporter.private}"];}
          # carbide, not running nginx
          {targets = ["${carbide}:${toString ports.node-exporter.private}"];}
        ];
      }
      {
        job_name = "promtail";
        static_configs = [
          # this pi (rpi1)
          {targets = ["promtail.${rpi1}"];}
          # rpi2
          {targets = ["promtail.${rpi2}"];}
          # xps15, not running nginx
          {targets = ["${xps15}:${toString ports.promtail.private}"];}
          # carbide, not running nginx
          {targets = ["${carbide}:${toString ports.promtail.private}"];}
        ];
      }
      {
        job_name = "nginx";
        static_configs = [
          # this pi (rpi1)
          {targets = ["nginx-exporter.${rpi1}"];}
          # rpi2
          {targets = ["nginx-exporter.${rpi2}"];}
        ];
      }
      {
        job_name = "dnsmasq";
        static_configs = [
          {targets = ["dnsmasq-exporter.${rpi1}"];}
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
