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
  passwordFileHomelab = pkgs.writeText "restic-password-local" ''
    homelab
  '';
  excludes = [
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
  local-repository = "/backups/${config.networking.hostName}/restic";
  homelab-repository = "sftp:root@cubenas.home.jeffas.net:/local/backups/${config.networking.hostName}/restic";
in {
  # environment.systemPackages = [
  #   pkgs.restic
  #   pkgs.prometheus-restic-exporter
  # ];

  services.restic.backups = {
    local = {
      user = "andrew";
      repository = local-repository;
      paths = ["/home/andrew"];
      exclude = excludes;
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

    homelab = {
      user = "andrew";
      repository = homelab-repository;
      paths = ["/home/andrew"];
      exclude = excludes;
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
  };

  systemd.services.prometheus-restic-exporter-local = {
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
      User = "andrew";
    };
    wantedBy = ["multi-user.target" "default.target"];
  };

  systemd.services.prometheus-restic-exporter-homelab = {
    enable = true;
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
      User = "andrew";
    };
    wantedBy = ["multi-user.target" "default.target"];
  };
}
