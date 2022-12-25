pkgs:
with pkgs;
  derivation {
    name = "colemakdh";
    builder = "${bash}/bin/bash";
    args = [./builder.sh];
    inherit coreutils gzip;
    src = ./.;
    system = "x86_64-linux";
  }
