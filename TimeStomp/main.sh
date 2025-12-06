#!/usr/bin/env bash

verbose=0
recursive=0
copy_source=""
mtime=""
atime=""
only_files=0
only_dirs=0

usage() {
    echo "Usage: $0 [options] <target>"
    echo ""
    echo "Options:"
    echo "  -v, --verbose              Verbose output"
    echo "  -r, --recursive            Process directories recursively"
    echo "  -c, --copy <file>          Copy timestamps from this file"
    echo "  -m, --mtime <timestamp>    Set modification time"
    echo "  -a, --atime <timestamp>    Set access time"
    echo "  -t, --time <timestamp>     Set access+modification"
    echo "  -f, --file                 Apply only to files"
    echo "  -d, --dir                  Apply only to directories"
    exit 1
}

# ------ Argument Parsing ------
while [[ $# -gt 0 ]]; do
    case "$1" in
        -v|--verbose)
            verbose=1; shift ;;
        -r|--recursive)
            recursive=1; shift ;;
        -c|--copy)
            if [[ -z "$2" ]]; then echo "Error: -c needs a source file"; exit 1; fi
            copy_source="$2"
            shift 2 ;;
        -m|--mtime)
            mtime="$2"; shift 2 ;;
        -a|--atime)
            atime="$2"; shift 2 ;;
        -t|--time)
            mtime="$2"
            atime="$2"
            shift 2 ;;
        -f|--file)
            only_files=1; shift ;;
        -d|--dir)
            only_dirs=1; shift ;;
        -*)
            echo "Unknown option: $1"; usage ;;
        *)
            target="$1"; shift ;;
    esac
done

# Must have target
[[ -z "$target" ]] && { echo "Error: No target file or directory specified."; usage; }

# Validate copy source
if [[ -n "$copy_source" ]]; then
    if [[ ! -f "$copy_source" ]]; then
        echo "Error: Copy source '$copy_source' is not a file."
        exit 1
    fi
    # Extract timestamps from source
    src_atime=$(stat -c %X "$copy_source")
    src_mtime=$(stat -c %Y "$copy_source")
fi

# Normalize date (using `date` to handle natural language)
normalize_date() {
    local date_input="$1"
    # `date -d` can handle strings like "yesterday", "now", or specific formats
    # Convert input to YYYY-MM-DD HH:MM:SS
    date -d "$date_input" +"%Y-%m-%d %H:%M:%S"
}

# ------ Apply timestamps ------
apply_stomp() {
    local path="$1"

    # skip mismatched types
    [[ $only_files -eq 1 && ! -f "$path" ]] && return
    [[ $only_dirs -eq 1 && ! -d "$path" ]] && return

    # copy timestamps
    if [[ -n "$copy_source" ]]; then
        atime="$src_atime"
        mtime="$src_mtime"
    fi

    # Normalize dates if needed
    if [[ -n "$mtime" ]]; then
        mtime=$(normalize_date "$mtime")
    fi

    if [[ -n "$atime" ]]; then
        atime=$(normalize_date "$atime")
    fi

    # build touch command safely
    cmd=(touch)

    [[ -n "$mtime" ]] && cmd+=("-m" "-d" "$mtime")
    [[ -n "$atime" ]] && cmd+=("-a" "-d" "$atime")

    cmd+=("$path")

    [[ $verbose -eq 1 ]] && echo "[+] touch command: ${cmd[*]}"

    "${cmd[@]}"
}

# ------ Process target ------
if [[ -d "$target" && $recursive -eq 1 ]]; then
    find "$target" -print0 | while IFS= read -r -d '' item; do
        apply_stomp "$item"
    done
else
    apply_stomp "$target"
fi

echo "[+] Done."
exit 0
