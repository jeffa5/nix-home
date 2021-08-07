pkgs:
pkgs.writeScriptBin "import-nef" ''
  #!${pkgs.stdenv.shell}

  shopt -s globstar

  source_dir=$1
  if [[ ! -d $source_dir ]]; then
    echo "Must provide a source dir"
    exit 1
  fi

  target_dir=$2
  if [[ ! -d $target_dir ]]; then
    echo "Must provide a target dir"
    exit 1
  fi

  count=$(ls -1 $source_dir/**/*.NEF | wc -l)
  new=0

  function process_file() {
    name=$(basename $file)
    dto=$(${pkgs.exiftool}/bin/exiftool -DateTimeOriginal $file)
    ymd=$(echo $dto | awk '{ print $4 }')
    hms=$(echo $dto | awk '{ print $5 }')
    year=$(echo $ymd | cut -d':' -f 1)
    month=$(echo $ymd | cut -d':' -f 2)
    day=$(echo $ymd | cut -d':' -f 3)
    hour=$(echo $hms | cut -d':' -f 1)
    minute=$(echo $hms | cut -d':' -f 2)
    second=$(echo $hms | cut -d':' -f 3)

    day_dir="$target_dir/$year/$month/$day"
    if [[ ! -d $day_dir ]]; then
      mkdir -p $day_dir
    fi

    hashsum=$(sha256sum $file | awk '{ print $1 }')

    new_name="$year-$month-$day-$hour-$minute-$second-$hashsum.NEF"
    new_path="$day_dir/$new_name"
    echo "$file -> $new_path"

    if [[ ! -f "$new_path" ]]; then
      ((new += 1))
    fi

    cp -n $file $new_path
  }

  function process_files() {
    ncpu=$(nproc)

    for file in $source_dir/**/*.NEF; do
      process_file $file &

      if [[ $(jobs -r -p | wc -l) -ge $ncpu ]]; then
        wait -n
      fi
    done

    wait
  }

  s=$(date +%s)
  process_files
  e=$(date +%s)

  echo
  echo "Imported $new new files out of $count total files in $((e - s)) seconds"
''
