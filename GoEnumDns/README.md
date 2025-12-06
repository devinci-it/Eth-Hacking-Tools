# DNS Enum Tool

A simple DNS enumeration script that uses `gobuster` and `dig` to discover subdomains of a target domain. It also downloads and caches a wordlist to avoid repeated downloads.

## Features
- DNS enumeration using `gobuster`.
- Uses `dig` to find authoritative nameserver IPs.
- Caches wordlist locally to prevent redundant downloads.
- Configurable DNS resolver, delay, and output options.
- Alias installation for convenient usage.

## Requirements

This tool depends on the following external programs:

- `dig` (from `dnsutils` or `bind-utils`)
- `gobuster`
- `curl`

### Installation on Debian/Ubuntu

```bash
sudo apt update
sudo apt install -y dnsutils gobuster curl
```

### Installation on CentOS/RHEL/Fedora

```
sudo dnf install -y bind-utils gobuster curl
```

### Installation on macOS (Homebrew)
```
brew install bind gobuster curl
```
## Installation

	1.	Clone the repository:
```
git clone <repository_url>
cd <repository_directory>
```

	2.	Make the install script executable and run it:
```
chmod +x install.sh
./install.sh
```
	3.	Source your shell configuration file or restart your terminal:

	•	For Bash:
```
source ~/.bashrc
```
	•	For Zsh:
```
source ~/.zshrc
```

## Usage

Run the tool using the alias dnsenum:
```
dnsenum -d example.com

Options
	•	-d, --domain <domain>: Target domain (required)
	•	-w, --wordlist <path>: Use a custom wordlist
	•	--check-cname: Check CNAME records
	•	--resolver <resolver>: Specify DNS resolver
	•	--delay <duration>: Delay between requests (default 150ms)
	•	--no-error, --ne: Suppress error output
	•	-o, --output <file>: Specify output file
``
For full usage details, run:
```
dnsenum --help
```
