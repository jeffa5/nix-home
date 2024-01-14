{configs}: {
  lib,
  config,
  ...
}: let
  hosts = import ../../hosts.nix;
  nodeEntries =
    lib.concatStringsSep "\n" (lib.mapAttrsToList (name: value: "${value} ${name}.home.jeffas.net") hosts);
  serviceEntriesForNode = name: nodeConfig: let
    services = nodeConfig.services.nginx.virtualHosts;
    ip = hosts.${name};
  in
    lib.concatStringsSep "\n" (lib.mapAttrsToList (_name: value:
      if value.serverName != null
      then "${ip} ${value.serverName}"
      else "")
    services);
  serviceEntries = lib.concatStringsSep "\n" (lib.mapAttrsToList (name: value: serviceEntriesForNode name value.config) configs);
in {
  services.dnsmasq = {
    enable = true;
    settings = {
      domain-needed = true;
      bogus-priv = true;
      server = [
        # cloudflare
        "1.1.1.1"
        "1.0.0.1"
        # google
        "8.8.8.8"
        "8.8.4.4"
      ];
      cache-size = 1024;
    };
  };

  networking.extraHosts = ''
    # node entries
    ${nodeEntries}

    # service entries
    ${serviceEntries}
  '';

  services.prometheus.exporters.dnsmasq = {
    enable = true;
    leasesPath = "/var/lib/dnsmasq/dnsmasq.leases";
  };

  services.nodeboard.services.dnsmasq-exporter = {
    name = "DNS Masq exporter";
    url = "http://dnsmasq-exporter.${config.networking.hostName}.home.jeffas.net";
  };

  services.nginx.virtualHosts."dnsmasq.local" = {
    serverName = "dnsmasq-exporter.${config.networking.hostName}.home.jeffas.net";
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString config.services.prometheus.exporters.dnsmasq.port}";
    };
  };
}
