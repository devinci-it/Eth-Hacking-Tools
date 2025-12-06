
#!/bin/bash


WORDLIST_URL="https://raw.githubusercontent.com/danielmiessler/SecLists/master/Discovery/DNS/subdomains-top1million-5000.txt"
WORDLIST_DIR="$HOME/.dns_enum_wordlists"
DEFAULT_WORDLIST="$WORDLIST_DIR/subdomains-top1million-5000.txt"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUTPUT_DIR="$SCRIPT_DIR/dns_enum_results"
DEFAULT_RESOLVER="8.8.8.8"
DEFAULT_DELAY="150ms"

usage() {
    cat << EOF
Usage: $0 -d <domain> [options]

Options:
  -d, --domain <domain>           Target domain for DNS enumeration (required)
  -w, --wordlist <path>           Override default DNS wordlist with a custom one
      --check-cname               Also check CNAME records (default: false)
      --resolver <resolver>       DNS resolver to use (default: auto-discovered or $DEFAULT_RESOLVER)
      --delay <duration>          Delay between requests (default: $DEFAULT_DELAY)
      --no-error, --ne            Suppress error output (default: false)
  -o, --output <file>             Specify an output file (optional)
  -h, --help                     Show this help message

Example:
  $0 -d example.com --check-cname --resolver 1.1.1.1 --delay 200ms
EOF
    exit 1
}

# Check required commands
for cmd in gobuster curl dig; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        echo "Error: Required command '$cmd' not found in PATH."
        exit 1
    fi
done

# Defaults
DOMAIN=""
WORDLIST=""
CHECK_CNAME=false
RESOLVER=""
DELAY="$DEFAULT_DELAY"
NO_ERROR=false
OUTPUT_FILE=""

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        -d|--domain)
            DOMAIN="$2"
            shift 2
            ;;
        -w|--wordlist)
            WORDLIST="$2"
            shift 2
            ;;
        --check-cname)
            CHECK_CNAME=true
            shift
            ;;
        --resolver)
            RESOLVER="$2"
            shift 2
            ;;
        --delay|-d)
            DELAY="$2"
            shift 2
            ;;
        --no-error|--ne)
            NO_ERROR=true
            shift
            ;;
        -o|--output)
            OUTPUT_FILE="$2"
            shift 2
            ;;
        -h|--help)
            usage
            ;;
        *)
            echo "Unknown argument: $1"
            usage
            ;;
    esac
done

if [[ -z "$DOMAIN" ]]; then
    echo "[ERROR] Target domain is required."
    usage
fi

# Prepare directories
mkdir -p "$WORDLIST_DIR"
mkdir -p "$OUTPUT_DIR"

# Update wordlist function (only update once per day)
update_wordlist() {
    local LAST_UPDATE_FILE="$WORDLIST_DIR/.last_update"

    # Check if updated within last 24 hours
    if [[ -f "$LAST_UPDATE_FILE" ]]; then
        local last_update_ts
        last_update_ts=$(cat "$LAST_UPDATE_FILE")

        # Current timestamp
        local now_ts
        now_ts=$(date +%s)

        # 86400 seconds = 24 hours
        if (( now_ts - last_update_ts < 86400 )); then
            echo "[i] Wordlist was already updated within the last 24 hours."
            echo "[i] Skipping download and using: $DEFAULT_WORDLIST"
            return 0
        fi
    fi

    echo "[*] Attempting to download/update DNS wordlist from SecLists..."
    if curl -fsSL "$WORDLIST_URL" -o "$DEFAULT_WORDLIST"; then
        echo "[+] Wordlist updated successfully at $DEFAULT_WORDLIST"
        # Write current timestamp
        date +%s > "$LAST_UPDATE_FILE"
    else
        echo "[!] Failed to fetch wordlist from online source."
        if [[ -f "$DEFAULT_WORDLIST" && -s "$DEFAULT_WORDLIST" ]]; then
            echo "[i] Falling back to existing local wordlist at $DEFAULT_WORDLIST"
        else
            echo "[ERROR] No usable local wordlist found at $DEFAULT_WORDLIST"
            echo "Please provide a custom wordlist with --wordlist or ensure internet connectivity."
            exit 1
        fi
    fi
}

# Find authoritative NS IPs for domain
find_ns_ip() {
    local domain="$1"
    local ns_ips=()

    for ns_candidate in "ns1.$domain" "ns2.$domain"; do
        ip=$(dig +short "$ns_candidate" A | head -n1)
        if [[ -n "$ip" ]]; then
            ns_ips+=("$ip")
        fi
    done

    if [[ ${#ns_ips[@]} -gt 0 ]]; then
        echo "[+] Found authoritative NS IP(s): ${ns_ips[*]}"
        echo "${ns_ips[0]}"
        RESOLVER="${ns_ips[0]}"
        return 0
        
    else
        echo "[i] No authoritative NS IP found, will use default resolver $DEFAULT_RESOLVER"
        echo "$DEFAULT_RESOLVER"
        return 1
    fi
}

# Use custom wordlist or update default one
if [[ -n "$WORDLIST" ]]; then
    if [[ ! -f "$WORDLIST" ]]; then
        echo "[ERROR] Custom wordlist specified but file does not exist: $WORDLIST"
        exit 1
    fi
    echo "[*] Using custom wordlist: $WORDLIST"
else
    update_wordlist
    WORDLIST="$DEFAULT_WORDLIST"
fi

# Determine resolver IP
find_ns_ip $DOMAIN
# Check the return status
if [[ $? -eq 0 ]]; then
    echo "Using RESOLVER: $RESOLVER"
else
    RESOLVER="$DEFAULT_RESOLVER"
    echo "No authoritative NS found. Using default RESOLVER: $RESOLVER"
fi

echo "[*] Using delay: $DELAY"

# If output file is not specified, create a temporary file
if [[ -z "$OUTPUT_FILE" ]]; then
    OUTPUT_FILE=$(mktemp "/tmp/${DOMAIN}_dns_enum_$(date +%Y%m%d_%H%M%S).txt")
fi
   
# Construct command string for logging
CMD_STR="gobuster dns --domain \"$DOMAIN\" --wordlist \"$WORDLIST\" --resolver \"$RESOLVER\" --delay \"$DELAY\" --threads 10"
$CHECK_CNAME && CMD_STR+=" --check-cname"
$NO_ERROR && CMD_STR+=" --no-error"

echo "[*] Running gobuster DNS enumeration..."
echo "### Command run:" > "$OUTPUT_FILE"
echo "$CMD_STR" >> "$OUTPUT_FILE"
echo "### Output:" >> "$OUTPUT_FILE"

# Run gobuster and tee output (append) to file and terminal
eval "$CMD_STR" 2>&1 | tee -a "$OUTPUT_FILE"

echo "[*] Enumeration complete. Results saved in $OUTPUT_FILE"
