{...}: let
  public_port = 9000;
  private_port = 9090;
  ports = import ./ports.nix;
in {
  services.prometheus = {
    enable = true;
    port = private_port;

    scrapeConfigs = [
      {
        job_name = "node-exporter";
        static_configs = [
          # this pi (rpi1)
          {targets = ["192.168.0.52:${toString ports.node-exporter.public}"];}
          # rpi2
          {targets = ["192.168.0.99:${toString ports.node-exporter.public}"];}
        ];
      }
      {
        job_name = "nginx";
        static_configs = [
          # this pi (rpi1)
          {targets = ["192.168.0.52:${toString ports.nginx-exporter.public}"];}
          # rpi2
          {targets = ["192.168.0.99:${toString ports.nginx-exporter.public}"];}
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
