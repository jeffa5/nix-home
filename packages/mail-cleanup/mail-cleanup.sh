#!/usr/bin/env bash
# mail-cleanup — interactive Maildir cleanup tool using mu.
# Ranks senders by message count, lets the user iteratively refine a mu
# query, and moves matching messages into ~/mail-cleanup/<account>/ Maildir
# folders. Never deletes.

set -uo pipefail

MODE=from
while [[ $# -gt 0 ]]; do
  case "$1" in
    --to|-t)   MODE=to;   shift ;;
    --from|-f) MODE=from; shift ;;
    *) printf 'mail-cleanup: unknown option: %s\n' "$1" >&2; exit 1 ;;
  esac
done

MAIL_ROOT="${HOME}/mail"
CLEANUP_ROOT="${HOME}/mail-cleanup"
SESSION_DIR=$(mktemp -d -t mail-trim.XXXXXX)
LEADERBOARD="$SESSION_DIR/leaderboard"
PREVIEW_HELPER="$SESSION_DIR/preview.sh"
trap 'rm -rf "$SESSION_DIR"' EXIT

cat > "$PREVIEW_HELPER" <<PREVIEW_EOF
#!/usr/bin/env bash
line="\$*"
contact=\$(printf '%s' "\$line" | awk '{print \$NF}')
[ -n "\$contact" ] || exit 0
path=\$(mu find --format=json --sortfield=d --reverse -n 1 "$MODE:\$contact" 2>/dev/null \
  | jq -r '.[0][":path"] // empty')
[ -n "\$path" ] && [ -f "\$path" ] || { printf '(no readable message)\n'; exit 0; }
mu view "\$path" 2>/dev/null | head -200
PREVIEW_EOF
chmod +x "$PREVIEW_HELPER"

err() { printf '%s\n' "$*" >&2; }

if [ ! -d "$MAIL_ROOT" ]; then
  err "mail-trim: $MAIL_ROOT does not exist"
  exit 1
fi

human_size() {
  numfmt --to=iec --suffix=B --format='%.1f' "${1:-0}" 2>/dev/null || printf '%sB' "${1:-0}"
}

compute_leaderboard() {
  printf 'Scanning mu index...\n' >&2
  local jq_filter
  if [ "$MODE" = from ]; then
    jq_filter='
      .[]
      | select((.[":path"] // "") | startswith($root) | not)
      | select((.[":path"] // "") | startswith($cleanup) | not)
      | [(.[":size"] // 0), ((.[":from"] // [{}])[0][":email"] // "(unknown)" | ascii_downcase)]
      | @tsv'
  else
    jq_filter='
      .[]
      | select((.[":path"] // "") | startswith($root) | not)
      | select((.[":path"] // "") | startswith($cleanup) | not)
      | . as $msg
      | (.[":to"] // [{}])[]
      | [$msg[":size"] // 0, (.[":email"] // "(unknown)" | ascii_downcase)]
      | @tsv'
  fi
  mu find --format=json '' 2>/dev/null \
    | jq -r --arg root "$MAIL_ROOT/search/" --arg cleanup "$CLEANUP_ROOT/" "$jq_filter" \
    | awk -F'\t' '
        { sz[$2]+=$1; ct[$2]++ }
        END { for (k in sz) printf "%d\t%d\t%s\n", ct[k], sz[k], k }
      ' \
    | sort -rn -k1,1 > "$LEADERBOARD"
  if [ ! -s "$LEADERBOARD" ]; then
    err "mail-trim: no messages found in mu index"
    return 1
  fi
}

format_leaderboard() {
  awk -F'\t' '
    function human(b,    units, i, x) {
      units[0]="B"; units[1]="KB"; units[2]="MB"; units[3]="GB"; units[4]="TB"
      x = b; i = 0
      while (x >= 1024 && i < 4) { x = x / 1024; i++ }
      return sprintf("%.1f%s", x, units[i])
    }
    { printf "%7d  %10s  %s\n", $1, human($2), $3 }
  ' "$LEADERBOARD"
}

pick_contacts() {
  local label
  label=$([ "$MODE" = from ] && printf 'sender' || printf 'recipient')
  format_leaderboard \
    | fzf --prompt="$label> " \
          --header="  count        size  $label — Tab to multi-select, Enter to confirm, Esc to quit" \
          --no-sort --reverse \
          --multi \
          --height=80% \
          --preview="$PREVIEW_HELPER {}" \
          --preview-window='right,60%,wrap' \
    | awk '{print $NF}'
}

stats_for() {
  local filter="$1"
  local json
  json=$(mu find --format=json "$filter" 2>/dev/null || true)
  if [ -z "$json" ] || [ "$json" = "[]" ]; then
    printf '0\t0\n'
    return
  fi
  jq -r --arg cleanup "$CLEANUP_ROOT/" \
      'map(select((.[":path"] // "") | startswith($cleanup) | not))
      | [length, (map(.[":size"] // 0) | add // 0)]
      | @tsv' <<<"$json"
}

show_preview() {
  local filter="$1"
  local out
  out=$(mu find --format=json --sortfield=d --reverse "$filter" 2>/dev/null \
    | jq -r --arg cleanup "$CLEANUP_ROOT/" '
        map(select((.[":path"] // "") | startswith($cleanup) | not))
        | .[0:10][]
        | [
            ((.[":date-unix"] // 0) | strftime("%Y-%m-%d")),
            (.[":size"] // 0 | tostring),
            (.[":subject"] // "(no subject)")
          ] | @tsv
      ')
  if [ -z "$out" ]; then
    printf '  (no messages match)\n'
    return
  fi
  awk -F'\t' '
    function human(b,    units, i, x) {
      units[0]="B"; units[1]="KB"; units[2]="MB"; units[3]="GB"
      x = b; i = 0
      while (x >= 1024 && i < 3) { x = x / 1024; i++ }
      return sprintf("%.0f%s", x, units[i])
    }
    {
      subj = $3
      if (length(subj) > 70) subj = substr(subj, 1, 67) "..."
      printf "  %s  %7s  %s\n", $1, human($2), subj
    }' <<<"$out"
}

derive_account() {
  local path="$1"
  local rel="${path#"$MAIL_ROOT"/}"
  if [ "$rel" = "$path" ]; then
    printf ''
    return
  fi
  printf '%s' "${rel%%/*}"
}

do_cleanup() {
  local filter="$1"
  local paths_file="$SESSION_DIR/paths"
  mu find --format=json "$filter" 2>/dev/null \
    | jq -r --arg cleanup "$CLEANUP_ROOT/" '
        .[]
        | select((.[":path"] // "") | startswith($cleanup) | not)
        | .[":path"] // empty' > "$paths_file"

  local n
  n=$(wc -l < "$paths_file" | tr -d ' ')
  if [ "$n" -eq 0 ]; then
    printf 'No matching messages.\n'
    return 1
  fi

  printf '\nMove %d messages into per-account cleanup folders? [y/N] ' "$n"
  local yn
  read -r yn
  case "$yn" in
    y|Y|yes|YES) ;;
    *) printf 'Aborted.\n'; return 1 ;;
  esac

  # Python does all renames in-process (no fork per file) and streams progress.
  python3 - "$MAIL_ROOT" "$CLEANUP_ROOT" "$paths_file" "$n" <<'PYEOF'
import sys, os

mail_root = sys.argv[1]
cleanup_root = sys.argv[2]
paths_file = sys.argv[3]
total = int(sys.argv[4])

moved = skipped = missing = 0

with open(paths_file) as f:
    paths = [p.rstrip('\n') for p in f if p.strip()]

for i, src in enumerate(paths, 1):
    sys.stderr.write(f'\rMoving {i}/{total}...')
    sys.stderr.flush()
    if not os.path.isfile(src):
        missing += 1
        continue
    rel = src.removeprefix(mail_root + '/')
    if rel == src:
        sys.stderr.write(f'\nmail-trim: path outside mail root: {src}\n')
        skipped += 1
        continue
    account = rel.split('/')[0]
    cleanup_cur = os.path.join(cleanup_root, account, 'cur')
    os.makedirs(os.path.join(cleanup_root, account, 'new'), exist_ok=True)
    os.makedirs(os.path.join(cleanup_root, account, 'tmp'), exist_ok=True)
    os.makedirs(cleanup_cur, exist_ok=True)
    base = os.path.basename(src)
    dst = os.path.join(cleanup_cur, base)
    if os.path.exists(dst):
        stem, _, flags = base.partition(':')
        rest = f':{flags}' if flags else ''
        dup = 0
        while os.path.exists(dst):
            dup += 1
            dst = os.path.join(cleanup_cur, f'{stem}.dup{dup}{rest}')
    try:
        os.rename(src, dst)
        moved += 1
    except OSError as e:
        sys.stderr.write(f'\nmail-trim: rename failed: {e}\n')
        skipped += 1

sys.stderr.write('\n')
parts = [f'Moved {moved}']
if skipped:  parts.append(f'{skipped} failed')
if missing:  parts.append(f'{missing} already gone')
print(', '.join(parts) + '.')
PYEOF
}

filter_loop() {
  local filter="$1"
  local -a history=()
  local action extra stats count size human last

  while true; do
    stats=$(stats_for "$filter")
    count=$(printf '%s' "$stats" | cut -f1)
    size=$(printf '%s' "$stats" | cut -f2)
    human=$(human_size "$size")

    printf '\n────────────────────────────────────────\n'
    printf 'Filter:  %s\n' "$filter"
    printf 'Matches: %s messages, %s\n\n' "$count" "$human"
    printf 'Preview (latest 10):\n'
    show_preview "$filter"
    printf '\n'

    if [ "${#history[@]}" -gt 0 ]; then
      printf '[r]efine  [u]ndo  [c]leanup  [s]kip  [q]uit > '
    else
      printf '[r]efine  [c]leanup  [s]kip  [q]uit > '
    fi
    read -r action
    case "$action" in
      r|R)
        printf 'additional mu terms (e.g. date:..2023, subject:digest)> '
        read -r extra
        if [ -n "$extra" ]; then
          history+=("$filter")
          filter="$filter AND $extra"
        fi
        ;;
      u|U)
        if [ "${#history[@]}" -gt 0 ]; then
          last=$((${#history[@]} - 1))
          filter="${history[$last]}"
          unset "history[$last]"
        else
          printf 'Nothing to undo.\n'
        fi
        ;;
      c|C)
        if do_cleanup "$filter"; then
          return 0
        fi
        ;;
      s|S|'') return 0 ;;
      q|Q) exit 0 ;;
      *) printf 'Unknown choice: %s\n' "$action" ;;
    esac
  done
}

main() {
  while true; do
    compute_leaderboard || exit 1
    local contacts_raw
    contacts_raw=$(pick_contacts) || { printf 'Bye.\n'; exit 0; }
    [ -n "$contacts_raw" ] || continue

    local -a contacts=()
    while IFS= read -r contact; do
      [ -n "$contact" ] && contacts+=("$contact")
    done <<<"$contacts_raw"

    local any_cleaned=0
    for contact in "${contacts[@]}"; do
      if filter_loop "$MODE:$contact"; then
        any_cleaned=1
      fi
    done

    if [ "$any_cleaned" -eq 1 ]; then
      printf '\nRe-indexing mu...\n'
      mu index || err "mail-trim: mu index failed"
    fi
  done
}

main "$@"
