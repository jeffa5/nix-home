{...}: let
  private_port = 9090;
  ports = import ./ports.nix;
  homeNet = "home.jeffas.net";
  cubenas = "cubenas.${homeNet}";
  rpi1 = "rpi1.${homeNet}";
  rpi2 = "rpi2.${homeNet}";
  xps15 = "xps15.${homeNet}";
  x1c6 = "x1c6.${homeNet}";
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
          {targets = ["node-exporter.${cubenas}"];}
          {targets = ["node-exporter.${rpi1}"];}
          {targets = ["node-exporter.${rpi2}"];}
          # xps15, not running nginx
          {targets = ["${xps15}:${toString ports.node-exporter.private}"];}
          # x1c6, not running nginx
          {targets = ["${x1c6}:${toString ports.node-exporter.private}"];}
          # carbide, not running nginx
          {targets = ["${carbide}:${toString ports.node-exporter.private}"];}
        ];
      }
      {
        job_name = "promtail";
        static_configs = [
          {targets = ["promtail.${cubenas}"];}
          {targets = ["promtail.${rpi1}"];}
          {targets = ["promtail.${rpi2}"];}
          # xps15, not running nginx
          {targets = ["${xps15}:${toString ports.promtail.private}"];}
          # x1c6, not running nginx
          {targets = ["${x1c6}:${toString ports.promtail.private}"];}
          # carbide, not running nginx
          {targets = ["${carbide}:${toString ports.promtail.private}"];}
        ];
      }
      {
        job_name = "nginx";
        static_configs = [
          {targets = ["nginx-exporter.${cubenas}"];}
          {targets = ["nginx-exporter.${rpi1}"];}
          {targets = ["nginx-exporter.${rpi2}"];}
        ];
      }
      {
        job_name = "dnsmasq";
        static_configs = [
          {targets = ["dnsmasq-exporter.${cubenas}"];}
        ];
      }
      {
        job_name = "wttr_in_london";
        static_configs = [
          {
            targets = ["wttr.in"];
            labels = {location = "london";};
          }
        ];
        metrics_path = "/London";
        params = {
          format = ["p1"];
        };
        scrape_interval = "1h";
        scheme = "https";
      }
    ];

    retentionTime = "5y";

    globalConfig = {
      scrape_interval = "30s";
    };
  };

  # wait for storage
  systemd.services.prometheus = {
    after = ["local.mount"];
    requires = ["local.mount"];
  };

  services.nginx.virtualHosts."Prometheus" = {
    inherit serverName;
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString private_port}";
      proxyWebsockets = true;
    };
  };
}
