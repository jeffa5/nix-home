{...}: let
  rpi1 = "100.85.109.140";
  xps15 = "100.125.129.20";
  carbide = "100.92.225.84";
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
    ${rpi1} rpi1.home.jeffas.net
    ${xps15} xps15.home.jeffas.net
    ${carbide} carbide.home.jeffas.net

    ${rpi1} grafana.home.jeffas.net
    ${rpi1} prometheus.home.jeffas.net
    ${rpi1} loki.home.jeffas.net
  '';

  services.prometheus.exporters.dnsmasq = {
    enable = true;
    openFirewall = false;
    leasesPath = "/var/lib/dnsmasq/dnsmasq.leases";
  };
}
