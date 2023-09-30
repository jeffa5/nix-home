{config, ...}: let
  public_port = 9000;
  private_port = 9090;
in {
  services.prometheus = {
    enable = true;
    port = private_port;

    scrapeConfigs = [
      {
        job_name = "node-exporter";
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

  services.nginx.virtualHosts."prometheus.local" = {
    # TODO: use DNS for this rather than relying on the ip
    serverName = "192.168.0.52:${toString public_port}";
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
