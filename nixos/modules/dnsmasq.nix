{...}: let
  rpi1 = "100.85.109.140";
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
    ${rpi1} grafana.jeffas.net
    ${rpi1} prometheus.jeffas.net
  '';
}
