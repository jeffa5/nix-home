{config, ...}: {
  services.prometheus = {
    enable = true;
    port = 9090;

    scrapeConfigs = [
      {
        job_name = "node-exporters";
        static_configs = [
          {targets = ["127.0.0.1:${toString config.services.prometheus.exporters.node.port}"];}
        ];
      }
      {
        job_name = "nginx";
        static_configs = [
          {targets = ["127.0.0.1:${toString config.services.prometheus.exporters.nginx.port}"];}
        ];
      }
    ];
  };
}
