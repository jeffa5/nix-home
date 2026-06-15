{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.services.duc;
in {
  options.services.duc = {
    enable = mkEnableOption "periodic duc disk usage indexing";

    paths = mkOption {
      type = types.listOf types.str;
      default = ["/"];
      description = "Paths to index with duc.";
    };

    excludes = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "Patterns to exclude from indexing.";
    };

    database = mkOption {
      type = types.path;
      default = "/var/lib/duc/duc.db";
      description = "Path to the duc database file.";
    };

    oneFileSystem = mkOption {
      type = types.bool;
      default = true;
      description = "Skip directories on different file systems (-x).";
    };

    onCalendar = mkOption {
      type = types.str;
      default = "daily";
      description = "systemd OnCalendar specification for the indexing timer.";
    };

    cgi = {
      enable = mkEnableOption "web view of the duc index via duc cgi";

      serverName = mkOption {
        type = types.str;
        default = "duc.home.jeffas.net";
        description = "Server name for the duc cgi virtual host.";
      };
    };
  };

  config = mkMerge [
    (mkIf cfg.enable {
      systemd.tmpfiles.rules = [
        "d ${dirOf cfg.database} 0755 root root -"
      ];

      systemd.services.duc-index = {
        description = "Update duc disk usage index";
        script = ''
          ${lib.getExe pkgs.duc} index \
            -d ${cfg.database} \
            ${optionalString cfg.oneFileSystem "-x"} \
            ${concatMapStringsSep " " (e: "-e ${escapeShellArg e}") cfg.excludes} \
            ${concatMapStringsSep " " escapeShellArg cfg.paths}
        '';
        serviceConfig = {
          Type = "oneshot";
          Nice = 19;
          IOSchedulingClass = "idle";
        };
      };

      systemd.timers.duc-index = {
        description = "Update duc disk usage index";
        wantedBy = ["timers.target"];
        timerConfig = {
          OnCalendar = cfg.onCalendar;
          Persistent = true;
        };
      };

      environment.systemPackages = [pkgs.duc];
    })

    (mkIf (cfg.enable && cfg.cgi.enable) (let
      authelia-snippets = import ./authelia-snippets.nix {inherit pkgs;};
      cgiScript = pkgs.writeShellScript "duc-cgi" ''
        exec ${lib.getExe pkgs.duc} cgi -d ${cfg.database}
      '';
    in {
      services.fcgiwrap.instances.duc = {
        socket = {
          type = "unix";
          user = "nginx";
          group = "nginx";
          mode = "0600";
        };
      };

      services.nginx.virtualHosts."Duc" = {
        serverName = cfg.cgi.serverName;
        locations."/" = {
          extraConfig = ''
            include ${authelia-snippets.authelia-authrequest};
            fastcgi_pass unix:${config.services.fcgiwrap.instances.duc.socket.address};
            fastcgi_param SCRIPT_FILENAME ${cgiScript};
            include ${config.services.nginx.package}/conf/fastcgi_params;
          '';
        };
        forceSSL = true;
        useACMEHost = "home.jeffas.net";
        extraConfig = ''
          include ${authelia-snippets.authelia-location};
        '';
      };
    }))
  ];
}
