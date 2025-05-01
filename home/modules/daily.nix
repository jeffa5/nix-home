{writeShellScriptBin}:
writeShellScriptBin "daily" (builtins.readFile ./daily.sh)
