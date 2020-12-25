pkgs:
with pkgs.legacyPackages.x86_64-linux;
derivation {
  name = "sway-scripts";
  builder = "${bash}/bin/bash";
  args = [ ./builder.sh ];
  inherit coreutils;
  src = ./src;
  system = "x86_64-linux";
}
