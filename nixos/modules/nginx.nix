{...}: {
  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    statusPage = true;
  };

  services.prometheus.exporters.nginx = {
    enable = true;
  };
}
