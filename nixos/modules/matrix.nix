{pkgs, ...}: let
  # server_name determines Matrix IDs: @andrew:jeffas.net
  # The actual server lives at matrix.home.jeffas.net (internal).
  # Federation uses .well-known at jeffas.net to point to matrix.jeffas.net:443
  # (via cloudflare tunnel — add when ready to federate).
  serverName = "jeffas.net";
  internalHostName = "matrix.home.jeffas.net";
  # Local port for the .well-known/matrix vhost served via cloudflare tunnel
  wellKnownPort = 3084;
  httpPort = 8008;

  # All Dendrite components share one PostgreSQL database (different table prefixes)
  dbConn = "postgresql:///dendrite?host=/var/run/postgresql";
in {
  nixpkgs.config.permittedInsecurePackages = ["olm-3.2.16"];

  # Generate the signing key on first boot if missing.
  # Dendrite does not auto-generate it.
  systemd.services.dendrite-keys = {
    description = "Generate dendrite signing key";
    before = ["dendrite.service"];
    requiredBy = ["dendrite.service"];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      if [ ! -f /var/lib/dendrite/matrix_key.pem ]; then
        mkdir -p /var/lib/dendrite
        ${pkgs.dendrite}/bin/generate-keys --private-key /var/lib/dendrite/matrix_key.pem
        chown dendrite:dendrite /var/lib/dendrite/matrix_key.pem
        chmod 600 /var/lib/dendrite/matrix_key.pem
      fi
    '';
  };

  # Generate the registration secret on first boot if missing.
  # Used by dendrite-create-account to create user accounts.
  systemd.services.dendrite-secrets = {
    description = "Generate dendrite registration secret";
    before = ["dendrite.service"];
    requiredBy = ["dendrite.service"];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    path = [pkgs.coreutils];
    script = ''
      if [ ! -f /var/lib/dendrite/env ]; then
        mkdir -p /var/lib/dendrite
        secret=$(tr -dc 'a-zA-Z0-9' < /dev/urandom 2>/dev/null | head -c 64)
        echo "REGISTRATION_SHARED_SECRET=$secret" > /var/lib/dendrite/env
        chmod 600 /var/lib/dendrite/env
        chown dendrite:dendrite /var/lib/dendrite/env
      fi
    '';
  };

  services.dendrite = {
    enable = true;
    # The module runs envsubst on the config, so ${VAR} is substituted at runtime
    environmentFile = "/var/lib/dendrite/env";
    settings = {
      global = {
        server_name = serverName;
        private_key = "/var/lib/dendrite/matrix_key.pem";
      };
      client_api = {
        registration_disabled = true;
        registration_shared_secret = "\${REGISTRATION_SHARED_SECRET}";
      };
      federation_api.disable_tls_validation = true;
      app_service_api.database.connection_string = dbConn;
      federation_api.database.connection_string = dbConn;
      key_server.database.connection_string = dbConn;
      media_api.database.connection_string = dbConn;
      room_server.database.connection_string = dbConn;
      sync_api.database.connection_string = dbConn;
      user_api = {
        account_database.connection_string = dbConn;
        device_database.connection_string = dbConn;
      };
      mscs.database.connection_string = dbConn;
      relay_api.database.connection_string = dbConn;
    };
  };

  services.postgresql = {
    ensureUsers = [
      {
        name = "dendrite";
        ensureDBOwnership = true;
      }
    ];
    ensureDatabases = ["dendrite"];
  };

  services.nginx.virtualHosts."Matrix" = {
    serverName = internalHostName;
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString httpPort}";
      proxyWebsockets = true;
    };
    forceSSL = true;
    useACMEHost = "home.jeffas.net";
  };

  # Serves .well-known/matrix/* for jeffas.net via cloudflare tunnel.
  # This tells clients where to find the homeserver, and tells other
  # Matrix servers where to federate (when the tunnel is enabled).
  services.nginx.virtualHosts."Matrix well-known" = {
    serverName = "jeffas.net";
    listen = [
      {
        addr = "127.0.0.1";
        port = wellKnownPort;
      }
    ];
    locations."/.well-known/matrix/server" = {
      return = "200 '{\"m.server\":\"matrix.jeffas.net:443\"}'";
      extraConfig = ''
        default_type application/json;
        add_header Access-Control-Allow-Origin *;
      '';
    };
    locations."/.well-known/matrix/client" = {
      return = "200 '{\"m.homeserver\":{\"base_url\":\"https://${internalHostName}\"}}'";
      extraConfig = ''
        default_type application/json;
        add_header Access-Control-Allow-Origin *;
      '';
    };
    locations."/" = {
      return = "404";
    };
  };

  services.cloudflared.tunnels."bb0853ce-9799-4f0f-9b0d-80250eae1002".ingress."jeffas.net" = {
    service = "http://127.0.0.1:${toString wellKnownPort}";
  };
}
