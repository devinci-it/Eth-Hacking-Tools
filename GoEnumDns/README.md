# GoEnumDns — DNS Enumeration Tool

A small, opinionated DNS enumeration helper that combines gobuster and dig to discover subdomains and gather authoritative nameserver information. The script downloads and caches a wordlist so it is not re-downloaded on every run.

## Features
- Subdomain discovery using gobuster (DNS mode).
- Uses dig to resolve authoritative nameserver IPs for the target domain.
- Caches downloaded wordlist locally to avoid repeated downloads.
- Configurable DNS resolver, request delay, and output path.
- Optional CNAME checking and quiet/error-suppression flags.
- Optional alias installation for convenient usage.

## Requirements

This project relies on the following external programs being available in your PATH:
- dig (from dnsutils or bind-utils)
- gobuster
- curl (for downloading the wordlist)

### Install on Debian/Ubuntu
```bash
sudo apt update
sudo apt install -y dnsutils gobuster curl
```

### Install on CentOS/RHEL/Fedora
```bash
sudo dnf install -y bind-utils gobuster curl
```

### Install on macOS (Homebrew)
```bash
brew install bind gobuster curl
```

## Installation

1. Clone the repository:
```bash
git https://github.com/devinci-it/Eth-Hacking-Tools
cd Eth-Hacking-Tools/GoEnumDns
```

2. Make the install script executable and run it (if provided):
```bash
chmod +x install.sh
./install.sh
```
The install script (if present) may create an alias or copy the script into a directory on your PATH. Read the script before running it.

3. Reload your shell configuration or restart your terminal:
- Bash:
```bash
source ~/.bashrc
```
- Zsh:
```bash
source ~/.zshrc
```

If you prefer to create a manual alias, add something like this to your shell config:
```bash
# adjust path to where dnsenum script lives
alias dnsenum="/path/to/GoEnumDns/main.sh"
```

## Usage

Basic usage:
```bash
dnsenum -d example.com
```

Full usage / help:
```bash
dnsenum --help
```

### Options
- -d, --domain <domain>     Target domain (required)
- -w, --wordlist <path>     Use a custom wordlist (path to file)
- --check-cname             Check and report CNAME records for found names
- --resolver <resolver>     Use custom DNS resolver (e.g. 1.1.1.1 or 8.8.8.8)
- --delay <duration>        Delay between requests (e.g. 150ms, 1s). Default: 150ms
- --no-error, --ne          Suppress error output
- -o, --output <file>       Write results to specified output file
- -h, --help                Show help and exit

### Examples
Run a basic scan using the default resolver:
```bash
dnsenum -d example.com
```

Run with a custom resolver and delay, write output to a file:
```bash
dnsenum -d example.com --resolver 1.1.1.1 --delay 300ms -o example-subdomains.txt
```

Use a custom local wordlist:
```bash
dnsenum -d example.com -w /path/to/wordlist.txt
```

Check CNAMEs and suppress non-fatal errors:
```bash
dnsenum -d example.com --check-cname --no-error
```

## Output
- Results are printed to stdout by default.
- Use `-o <file>` to write output to a file.
- The script may also print progress or informational messages depending on flags; use `--no-error` to reduce noise.

## Notes and tips
- Ensure gobuster and dig are installed and accessible via PATH.
- If you run many concurrent lookups or lower the delay, be aware of rate limits and potential blocking by DNS providers.
- Wordlist caching avoids re-downloading the same list; if you want the freshest list, remove the cached file (path depends on the script).
- Inspect the install script before running it if you are in an environment with strict security policies.

## License
See the repository LICENSE file for licensing details.

