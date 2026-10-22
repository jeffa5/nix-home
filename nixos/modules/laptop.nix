{pkgs, ...}: let
  netdataPort = 19998;
  # Same pinned tarball nixpkgs bundles with withCloudUi = true. Serving it
  # from nginx instead keeps netdata on the binary cache: the override changes
  # netdata's derivation hash and forces a full C/Go/Rust build from source.
  netdataDashboard = pkgs.fetchzip {
    url = "https://web.archive.org/web/20251210212517if_/https://app.netdata.cloud/agent.tar.gz";
    hash = "sha256-8ovYkvt324l6f0YT6wTG+Y2u7VaVqotAdssnNTtHIEk=";
  };
in {
  # power
  powerManagement.enable = true;
  services.thermald.enable = true;

  # local battery/system monitoring, web UI on localhost:19999 via nginx
  services.netdata.enable = true;
  services.netdata.config.web."bind to" = "127.0.0.1:${toString netdataPort}";

  services.nginx.enable = true;
  # Other modules define vhosts (alloy, node-exporter) that would otherwise
  # listen on all interfaces once nginx is enabled here.
  services.nginx.defaultListenAddresses = ["127.0.0.1"];
  services.nginx.virtualHosts."Netdata" = {
    serverName = "localhost";
    listen = [
      {
        addr = "127.0.0.1";
        port = 19999;
      }
    ];
    root = "${netdataDashboard}/agent";
    locations."/".tryFiles = "$uri $uri/ @netdata";
    locations."@netdata" = {
      proxyPass = "http://127.0.0.1:${toString netdataPort}";
      proxyWebsockets = true;
    };
  };
  # conflicts with auto-cpufreq
  services.tlp.enable = false;
  services.auto-cpufreq = {
    enable = false;
    settings = {
      battery = {
        governor = "powersave";
        turbo = "never";
      };
      charger = {
        governor = "performance";
        turbo = "auto";
      };
    };
  };
}
