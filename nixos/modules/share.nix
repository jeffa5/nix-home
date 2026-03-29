{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.services.share;

  shareScript = pkgs.writeShellScriptBin "share" ''
    set -euo pipefail

    SHARE_DIR="${cfg.directory}"
    SHARE_URL="${cfg.url}"
    MAX_SIZE_BYTES=$((${toString cfg.maxSizeGB} * 1024 * 1024 * 1024))

    usage() {
        cat <<EOF
    Usage: share [OPTIONS] <file|directory>

    Share files via $SHARE_URL

    Options:
        -n, --name NAME    Use custom name instead of UUID (keeps extension)
        -k, --keep         Keep original filename (no UUID)
        -f, --force        Skip size limit check
        -h, --help         Show this help

    Examples:
        share photo.jpg              # -> $SHARE_URL/a1b2c3d4.jpg
        share ~/Documents/report     # -> $SHARE_URL/e5f6g7h8.zip
        share -n vacation photos/    # -> $SHARE_URL/vacation.zip
    EOF
        exit 0
    }

    error() {
        echo "Error: $1" >&2
        exit 1
    }

    human_size() {
        local bytes=$1
        if ((bytes >= 1073741824)); then
            printf "%.1f GB" "$(echo "scale=1; $bytes / 1073741824" | bc)"
        elif ((bytes >= 1048576)); then
            printf "%.1f MB" "$(echo "scale=1; $bytes / 1048576" | bc)"
        elif ((bytes >= 1024)); then
            printf "%.1f KB" "$(echo "scale=1; $bytes / 1024" | bc)"
        else
            printf "%d bytes" "$bytes"
        fi
    }

    # Parse arguments
    custom_name=""
    keep_name=false
    force=false

    while [[ $# -gt 0 ]]; do
        case $1 in
            -n|--name)
                custom_name="$2"
                shift 2
                ;;
            -k|--keep)
                keep_name=true
                shift
                ;;
            -f|--force)
                force=true
                shift
                ;;
            -h|--help)
                usage
                ;;
            -*)
                error "Unknown option: $1"
                ;;
            *)
                break
                ;;
        esac
    done

    [[ $# -lt 1 ]] && error "No file or directory specified. Use --help for usage."

    target="$1"
    [[ ! -e "$target" ]] && error "Path does not exist: $target"

    # Generate UUID for filename
    uuid=$(${pkgs.util-linux}/bin/uuidgen | tr '[:upper:]' '[:lower:]')

    # Determine if we need to zip
    needs_zip=false
    if [[ -d "$target" ]]; then
        needs_zip=true

        # Early size check for directories
        echo "Calculating directory size..."
        uncompressed_size=$(du -sb "$target" | cut -f1)
        if ((uncompressed_size > MAX_SIZE_BYTES)); then
            echo "Warning: Uncompressed size is $(human_size $uncompressed_size)"
            echo "Compressed size will likely exceed ${toString cfg.maxSizeGB}GB limit."
            read -p "Continue anyway? [y/N] " -n 1 -r
            echo
            [[ ! $REPLY =~ ^[Yy]$ ]] && exit 1
        elif ((uncompressed_size > MAX_SIZE_BYTES / 2)); then
            echo "Note: Uncompressed size is $(human_size $uncompressed_size)"
            echo "Compressed size may approach the ${toString cfg.maxSizeGB}GB limit depending on content."
            read -p "Continue? [Y/n] " -n 1 -r
            echo
            [[ $REPLY =~ ^[Nn]$ ]] && exit 1
        fi
    fi

    # Determine output filename
    if [[ -n "$custom_name" ]]; then
        if $needs_zip; then
            out_name="''${custom_name}.zip"
        else
            ext="''${target##*.}"
            if [[ "$ext" != "$target" && -n "$ext" ]]; then
                out_name="''${custom_name}.''${ext}"
            else
                out_name="$custom_name"
            fi
        fi
    elif $keep_name; then
        if $needs_zip; then
            base=$(basename "$target")
            out_name="''${base}.zip"
        else
            out_name=$(basename "$target")
        fi
    else
        if $needs_zip; then
            out_name="''${uuid}.zip"
        else
            ext="''${target##*.}"
            if [[ "$ext" != "$target" && -n "$ext" ]]; then
                out_name="''${uuid}.''${ext}"
            else
                out_name="$uuid"
            fi
        fi
    fi

    out_path="''${SHARE_DIR}/''${out_name}"

    # Check if output already exists
    [[ -e "$out_path" ]] && error "File already exists: $out_path"

    # Create zip or copy file
    if $needs_zip; then
        echo "Creating zip archive..."
        tmp_zip=$(mktemp --suffix=.zip)
        trap 'rm -f "$tmp_zip"' EXIT

        (cd "$(dirname "$target")" && ${pkgs.zip}/bin/zip -r -q "$tmp_zip" "$(basename "$target")")

        size=$(stat -c%s "$tmp_zip")
    else
        size=$(stat -c%s "$target")
    fi

    # Check size
    if ! $force && ((size > MAX_SIZE_BYTES)); then
        error "File size $(human_size $size) exceeds limit of $(human_size $MAX_SIZE_BYTES). Use --force to override."
    fi

    # Copy to share directory
    if $needs_zip; then
        mv "$tmp_zip" "$out_path"
        trap - EXIT
    else
        cp "$target" "$out_path"
    fi

    chmod 644 "$out_path"

    echo ""
    echo "Shared: $(human_size $size)"
    echo "''${SHARE_URL}/''${out_name}"
  '';
in {
  options.services.share = {
    enable = mkEnableOption "file sharing service";

    directory = mkOption {
      type = types.path;
      default = "/local/share";
      description = "Directory where shared files are stored";
    };

    url = mkOption {
      type = types.str;
      default = "https://share.jeffas.net";
      description = "Public URL for the share service";
    };

    maxSizeGB = mkOption {
      type = types.int;
      default = 10;
      description = "Maximum file size in GB";
    };

    port = mkOption {
      type = types.port;
      default = 3083;
      description = "Port for nginx to listen on";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [shareScript];

    systemd.tmpfiles.rules = [
      "d ${cfg.directory} 0755 root root -"
    ];
  };
}
