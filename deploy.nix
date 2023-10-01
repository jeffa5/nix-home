{
  lib,
  writeShellScriptBin,
  hosts,
}: let
  deploy = host: ip: "nixos-rebuild switch --flake .#${host} --fast --build-host root@${ip} --target-host root@${ip}";
  lines =
    lib.attrsets.mapAttrsToList (name: value: (
      deploy name value
    ))
    hosts;
  script = lib.concatStringsSep "\n" lines;
in
  writeShellScriptBin "deploy" ''
    set -x
    ${script}
  ''
