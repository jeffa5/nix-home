{writeShellScriptBin}:
writeShellScriptBin "daily" ''
  wiki="$HOME/Cloud/Obsidian/Home"
  daily_dir="journal/daily"
  day=$(date +%F-%A)

  cd $wiki
  mkdir -p $daily_dir
  nvim $daily_dir/$day.md
''
