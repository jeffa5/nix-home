set -eu

wiki="$HOME/wiki"
daily_dir="journal/daily"
day=$(date +%F-%A)
note_path="$day.md"

mkdir -p "$wiki/$daily_dir"
cd "$wiki/$daily_dir"

last="$(ls -1 | tail -1)"

if ! test -f "$note_path"; then
    if test -f "$last"; then
        sed -i -e "s/\[Next one\]()/\[Next one\]($note_path)/" "$last"
    else
        last=""
    fi
    cat <<EOF > "$note_path"
# $(date '+%A %d %B %Y')

[Last one]($last)
[Next one]()

## Tickets

## Notes

## Discussions
EOF
fi

nvim "$note_path"
