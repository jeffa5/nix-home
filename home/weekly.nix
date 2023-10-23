{writeShellScriptBin}:
writeShellScriptBin "weekly" ''
  project=~/projects/weeklies
  year=$(date +%Y)
  week=$(date +%V)

  weekdir=$project/$year/$week

  branch=apj39-$year-$week

  mkdir -p $weekdir
  cd ~/projects/weeklies

  git checkout $branch || git checkout main && git checkout -b $branch

  nvim $weekdir/apj39.md

  cd -
''
