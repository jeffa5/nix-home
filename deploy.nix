{
  lib,
  writeShellScriptBin,
  hosts,
}: let
  deploy = host: ip: let
    cmd = "nixos-rebuild switch --flake .#${host} --show-trace --no-reexec --build-host root@${ip} --target-host root@${ip}";
  in ''
    echo "+ ${cmd}"
    ${cmd}
  '';
  lines =
    lib.attrsets.mapAttrsToList (name: value: (
      let
        dep = deploy name value;
      in ''
        if [[ "$1" == "${name}" ]]; then
          ${dep}
        fi
      ''
    ))
    hosts;
  script = lib.concatStringsSep "\n" lines;
in
  writeShellScriptBin "deploy" ''
    if [[ "$1" == "" ]]; then
      echo "Please pass the host to deploy to"
      exit 1
    fi

    while [[ "$1" != "" ]]; do
      ${script}
      shift
    done
  ''
