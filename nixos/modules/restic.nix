{
  pkgs,
  config,
  ...
}: let
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
in {
  environment.systemPackages = [
    pkgs.restic
  ];

  services.restic.backups = {
    local = {
      user = "andrew";
      repository = "/backups/${config.networking.hostName}/restic";
      paths = ["/home/andrew"];
      exclude = excludes;
      initialize = true;
      passwordFile = "${passwordFileLocal}";
      extraBackupArgs = ["-vv"];
    };

    homelab = {
      user = "andrew";
      repository = "sftp:root@cubenas.home.jeffas.net:/local/backups/${config.networking.hostName}/restic";
      paths = ["/home/andrew"];
      exclude = excludes;
      initialize = true;
      timerConfig = {
        OnCalendar = "hourly";
      };
      passwordFile = "${passwordFileHomelab}";
      extraBackupArgs = ["-vv"];
    };
  };
}
