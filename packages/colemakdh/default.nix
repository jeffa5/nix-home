pkgs: let
  lib = pkgs.lib;
in
  derivation {
    name = "colemakdh";
    builder = lib.getExe pkgs.bash;
    args = [./builder.sh];
    inherit (pkgs) coreutils gzip;
    src = ./.;
    system = "x86_64-linux";
  }
