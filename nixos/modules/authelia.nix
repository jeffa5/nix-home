{
  pkgs,
  config,
  ...
}: let
  port = 9091;

  # Create a script to generate Authelia users.yaml from NixOS user configs
  generateUsersScript = let
    jq = pkgs.lib.getExe pkgs.jq;
    usersWithPasswords = pkgs.lib.filterAttrs (_: user: user.hashedPasswordFile != null) config.users.users;
    userEntries = pkgs.lib.mapAttrsToList (name: user: ''
      password=$(tr -d '\n' < "${user.hashedPasswordFile}")
      users=$(${jq} -n \
        --argjson existing "$users" \
        --arg name "${name}" \
        --arg displayname "${user.description or name}" \
        --arg password "$password" \
        --arg email "${name}@jeffas.net" \
        --argjson groups '${builtins.toJSON user.extraGroups}' \
        '$existing + {($name): {displayname: $displayname, password: $password, email: $email, groups: $groups}}')
    '') usersWithPasswords;
  in pkgs.writeShellScript "generate-authelia-users" ''
    set -euo pipefail
    users='{}'
    ${pkgs.lib.concatStringsSep "\n" userEntries}
    ${jq} -n --argjson users "$users" '{users: $users}'
  '';
in {
  environment.systemPackages = [pkgs.authelia];

  # Generate the authelia users file from password files
  systemd.services.authelia-home.after = ["redis-authelia.service"];
  systemd.services.authelia-home.wants = ["redis-authelia.service"];

  systemd.services.authelia-home.preStart = ''
    mkdir -p /var/lib/authelia-home
    ${generateUsersScript} > /var/lib/authelia-home/users.yaml
    chmod 600 /var/lib/authelia-home/users.yaml
  '';

  services.authelia.instances.home = {
    enable = true;
    secrets.storageEncryptionKeyFile = "/etc/authelia/storageEncryptionKeyFile";
    secrets.jwtSecretFile = "/etc/authelia/jwtSecretFile";
    secrets.oidcHmacSecretFile = "/etc/authelia/oidcHmacSecret";
    secrets.oidcIssuerPrivateKeyFile = "/etc/authelia/oidcPrivateKey";
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

  services.redis.servers.authelia = {
    enable = true;
    save = [
      [900 1]
      [300 10]
      [60 10000]
    ];
  };
  users.users.authelia-home.extraGroups = ["redis-authelia"];

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
