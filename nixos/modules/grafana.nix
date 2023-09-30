{config, ...}: {
  services.grafana = {
    enable = true;
    settings.server = {
      http_port = 3000;
    };
    provision = {
      enable = true;
      datasources.settings.datasources = [
        {
          name = "Prometheus";
          url = "127.0.0.1:${toString config.services.prometheus.port}";
          type = "Prometheus";
        }
      ];
    };
  };
}
