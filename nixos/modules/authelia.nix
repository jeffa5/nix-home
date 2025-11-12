{pkgs, ...}: let
  port = 9091;
in {
  environment.systemPackages = [pkgs.authelia];

  services.authelia.instances.home = {
    enable = true;
    secrets.storageEncryptionKeyFile = "/etc/authelia/storageEncryptionKeyFile";
    secrets.jwtSecretFile = "/etc/authelia/jwtSecretFile";
    settingsFiles = [./authelia-config.yaml];
    settings = {
      theme = "light";
      default_2fa_method = "totp";
      log.level = "debug";
      server.disable_healthcheck = true;
    };
  };

  services.postgresql.ensureUsers = [
    {
      name = "authelia-home";
      ensureDBOwnership = true;
    }
  ];
  services.postgresql.ensureDatabases = ["authelia-home"];

  services.nginx.virtualHosts."Authelia" = {
    serverName = "authelia.home.jeffas.net";
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString port}";
      proxyWebsockets = true;
    };
    forceSSL = true;
    useACMEHost = "home.jeffas.net";
  };
}
