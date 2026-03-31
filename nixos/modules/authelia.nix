{
  pkgs,
  config,
  ...
}: let
  port = 9091;

  # Create a script to generate Authelia users.yaml from NixOS user configs
  generateUsersScript = let
    usersWithPasswords = pkgs.lib.filterAttrs (_: user: user.hashedPasswordFile != null) config.users.users;
    userLines = pkgs.lib.mapAttrsToList (name: user: ''
      echo "${name}:"
      echo "  displayname: \"${user.description or name}\""
      echo -n "  password: \""
      cat "${user.hashedPasswordFile}"
      echo "\""
      echo "  email: \"${name}@jeffas.net\""
      echo "  groups: [${pkgs.lib.concatStringsSep ", " user.extraGroups}]"
    '') usersWithPasswords;
  in pkgs.writeShellScript "generate-authelia-users" ''
    set -euo pipefail
    ${pkgs.lib.concatStringsSep "\n" userLines}
  '';
in {
  environment.systemPackages = [pkgs.authelia];

  # Generate the authelia users file from password files
  systemd.services.authelia-home.preStart = ''
    mkdir -p /var/lib/authelia-home
    ${generateUsersScript} > /var/lib/authelia-home/users.yaml
    chmod 600 /var/lib/authelia-home/users.yaml
  '';

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
