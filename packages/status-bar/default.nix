pkgs:
with pkgs;
  derivation {
    name = "status-bar";
    builder = "${bash}/bin/bash";
    args = [./builder.sh];
    inherit coreutils;
    src = ./src;
    system = "x86_64-linux";
  }
