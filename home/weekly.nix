{writeShellScriptBin}:
writeShellScriptBin "weekly" ''
  weekdir=~/projects/weeklies/$(date +%Y)/$(date +%V)

  mkdir -p $weekdir
  cd ~/projects/weeklies
  nvim $weekdir/apj39.md
  cd -
''
