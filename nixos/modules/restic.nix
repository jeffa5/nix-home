{
  pkgs,
  config,
  lib,
  ...
}: let
  ports = import ./ports.nix;
  passwordFileLocal = pkgs.writeText "restic-password-local" ''
    local
  '';
  passwordFileHomelab = pkgs.writeText "restic-password-homelab" ''
    homelab
  '';
  passwordFileStorageBox = "/etc/restic/storagebox-pass";
  local-repository = "/backups/${config.networking.hostName}/restic";
  homelab-repository = "sftp:root@cubenas.home.jeffas.net:/local/backups/${config.networking.hostName}/restic";
  storagebox-repository = "sftp:u503028@u503028.your-storagebox.de:/backups/${config.networking.hostName}/restic";

  cfg = config.services.backups;
in {
  options = {
    services.backups = {
      enable = lib.mkEnableOption "backup services";
      local = lib.mkOption {
        type = lib.types.bool;
        default = true;
      };
      homelab = lib.mkOption {
        type = lib.types.bool;
        default = true;
      };
      storagebox = lib.mkOption {
        type = lib.types.bool;
        default = true;
      };
      extraStorageboxArgs = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
      };
      user = lib.mkOption {
        type = lib.types.str;
      };
      paths = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = ["/home/${cfg.user}"];
      };
      excludes = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [
          ".cache"
          ".bundle" # ruby
          ".cargo" # rust
          ".rustup" # rust
          ".julia" # julia
          "target/" # rust
          "_opam/" # ocaml
          "_build/" # ocaml
          ".npm" # node
          "node_modules/" # node
          "venv/" # python
          ".venv/" # python
        ];
      };
    };
  };

  config = lib.mkIf cfg.enable {
    # environment.systemPackages = [
    #   pkgs.restic
    #   pkgs.prometheus-restic-exporter
    # ];

    services.restic.backups = {
      local = lib.mkIf cfg.local {
        user = cfg.user;
        repository = local-repository;
        paths = cfg.paths;
        exclude = cfg.excludes;
        initialize = true;
        passwordFile = "${passwordFileLocal}";
        # extraBackupArgs = ["-vv"];
        checkOpts = [
          "--with-cache"
        ];
        pruneOpts = [
          "--keep-hourly 24"
          "--keep-daily 7"
          "--keep-weekly 5"
          "--keep-monthly 12"
          "--keep-yearly 100"
        ];
      };

      homelab = lib.mkIf cfg.homelab {
        user = cfg.user;
        repository = homelab-repository;
        paths = cfg.paths;
        exclude = cfg.excludes;
        initialize = true;
        timerConfig = {
          OnCalendar = "hourly";
        };
        passwordFile = "${passwordFileHomelab}";
        # extraBackupArgs = ["-vv"];
        checkOpts = [
          "--with-cache"
        ];
        pruneOpts = [
          "--keep-hourly 24"
          "--keep-daily 7"
          "--keep-weekly 5"
          "--keep-monthly 12"
          "--keep-yearly 100"
        ];
      };

      storagebox = lib.mkIf cfg.storagebox {
        user = cfg.user;
        repository = storagebox-repository;
        paths = cfg.paths;
        exclude = cfg.excludes;
        initialize = true;
        timerConfig = {
          OnCalendar = "hourly";
        };
        passwordFile = passwordFileStorageBox;
        extraBackupArgs = cfg.extraStorageboxArgs;
        checkOpts = [
          "--with-cache"
        ];
        pruneOpts = [
          "--keep-hourly 24"
          "--keep-daily 7"
          "--keep-weekly 5"
          "--keep-monthly 12"
          "--keep-yearly 100"
        ];
      };
    };

    systemd.services.prometheus-restic-exporter-local = lib.mkIf cfg.local {
      enable = true;
      description = "Export metrics for restic";
      script = ''
        ${lib.getExe pkgs.prometheus-restic-exporter} --listen-address :${toString ports.restic-exporter-local.private} --refresh-interval 5m --repo-name local --ignore-errors --restic-binary ${lib.getExe pkgs.restic} --print-command-output-on-error
      '';
      environment = {
        RESTIC_REPOSITORY = local-repository;
        RESTIC_PASSWORD_FILE = passwordFileLocal;
      };
      serviceConfig = {
        Type = "simple";
        User = cfg.user;
      };
      wantedBy = ["multi-user.target" "default.target"];
    };

    systemd.services.prometheus-restic-exporter-homelab = lib.mkIf cfg.homelab {
      enable = true;
      path = [config.programs.ssh.package];
      description = "Export metrics for restic";
      script = ''
        ${lib.getExe pkgs.prometheus-restic-exporter} --listen-address :${toString ports.restic-exporter-homelab.private} --refresh-interval 5m --repo-name homelab --ignore-errors --restic-binary ${lib.getExe pkgs.restic} --print-command-output-on-error
      '';
      environment = {
        RESTIC_REPOSITORY = homelab-repository;
        RESTIC_PASSWORD_FILE = passwordFileHomelab;
      };
      serviceConfig = {
        Type = "simple";
        User = cfg.user;
      };
      wantedBy = ["multi-user.target" "default.target"];
    };

    systemd.services.prometheus-restic-exporter-storagebox = lib.mkIf cfg.storagebox {
      enable = true;
      description = "Export metrics for restic";
      path = [config.programs.ssh.package];
      script = ''
        ${lib.getExe pkgs.prometheus-restic-exporter} --listen-address :${toString ports.restic-exporter-storagebox.private} --refresh-interval 5m --repo-name storagebox --ignore-errors --restic-binary ${lib.getExe pkgs.restic} --print-command-output-on-error
      '';
      environment = {
        RESTIC_REPOSITORY = storagebox-repository;
        RESTIC_PASSWORD_FILE = passwordFileStorageBox;
      };
      serviceConfig = {
        Type = "simple";
        User = cfg.user;
      };
      wantedBy = ["multi-user.target" "default.target"];
    };
  };
}
