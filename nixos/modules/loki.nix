{...}: let
  ports = (import ./ports.nix).loki;
  serverName = "loki.home.jeffas.net";
  private_port = ports.private;
in {
  services.loki = {
    enable = true;
    configuration = {
      # This is a complete configuration to deploy Loki backed by the filesystem.
      # The index will be shipped to the storage via tsdb-shipper.

      server.http_listen_port = private_port;
      auth_enabled = false;

      common = {
        ring = {
          instance_addr = "127.0.0.1";
          kvstore = {
            store = "inmemory";
          };
        };
        replication_factor = 1;
        path_prefix = "/var/lib/loki";
      };

      schema_config = {
        configs = [
          {
            from = "2022-06-06";
            store = "tsdb";
            object_store = "filesystem";
            schema = "v13";
            index = {
              prefix = "index_";
              period = "24h";
            };
          }
        ];
      };

      storage_config = {
        filesystem = {
          directory = "/var/lib/loki/chunks";
        };
      };
    };
  };

  # wait for storage
  systemd.services.loki = {
    after = ["local.mount"];
    requires = ["local.mount"];
  };

  services.nginx.virtualHosts."Loki" = {
    inherit serverName;
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString private_port}";
      proxyWebsockets = true;
    };
  };
}
