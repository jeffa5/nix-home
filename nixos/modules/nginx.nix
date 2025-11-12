{config, ...}: let
  ports = (import ./ports.nix).nginx-exporter;
  domainName = "jeffas.net";
  homeDomainName = "home.${domainName}";
in {
  security.acme = {
    acceptTerms = true;
    defaults.email = "dev+acme@${domainName}";
    certs = {
      "${homeDomainName}" = {
        domain = "*.${homeDomainName}";
        group = config.services.nginx.group;
        dnsProvider = "cloudflare";
        extraDomainNames = [homeDomainName];
        # location of your CLOUDFLARE_DNS_API_TOKEN=[value]
        environmentFile = "/etc/acme/cloudflare";
        reloadServices = ["nginx"];
      };
    };
  };

  services.nginx = {
    enable = true;
    recommendedTlsSettings = true;
    recommendedOptimisation = true;
    recommendedGzipSettings = true;
    recommendedProxySettings = true;
    statusPage = true;
  };

  services.prometheus.exporters.nginx = {
    enable = true;
    port = ports.private;
  };

  services.nginx.virtualHosts."Nginx Exporter" = {
    serverName = "nginx-exporter.${config.networking.hostName}.home.jeffas.net";
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString ports.private}";
      proxyWebsockets = true;
    };
  };
}
