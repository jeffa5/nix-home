{
  pkgs,
  config,
  ...
}: let
  passwordFileLocal = pkgs.writeText "restic-password-local" ''
    local
  '';
  excludes = [
    ".cache"
    ".bundle" # ruby
    ".cargo" # rust
    ".rustup" # rust
    ".julia" # julia
    "*/target" # rust
    "*/_opam" # ocaml
    "*/_build" # ocaml
    ".npm/_cacache" # node
    "*/node_modules" # node
    "*/venv" # python
    "*/.venv" # python
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
      exclude = map (x: "/home/*/" + x) excludes;
      initialize = true;
      passwordFile = "${passwordFileLocal}";
      extraBackupArgs = ["-vv"];
    };
  };
}
