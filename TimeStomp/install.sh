#!/usr/bin/env bash

set -e

echo "[*] Installing TimeStomp..."

# --- Locate script directory ---
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TARGET="$SCRIPT_DIR/main.sh"

# Ensure main.sh exists
if [[ ! -f "$TARGET" ]]; then
    echo "[!] main.sh not found at: $TARGET"
    exit 1
fi

echo "[*] Found main.sh at $TARGET"

# --- Install into /usr/local/bin ---
INSTALL_PATH="/usr/local/bin/timestomp"

sudo cp "$TARGET" "$INSTALL_PATH"
sudo chmod +x "$INSTALL_PATH"

echo "[*] Installed timestomp to $INSTALL_PATH"
echo "[*] Marked executable."

# --- Detect appropriate profile file ---
detect_profile() {
    if [[ -n "$ZSH_VERSION" ]]; then echo "$HOME/.zshrc"
    elif [[ -n "$BASH_VERSION" ]]; then echo "$HOME/.bashrc"
    elif [[ -f "$HOME/.profile" ]]; then echo "$HOME/.profile"
    else echo "$HOME/.bashrc"
    fi
}

PROFILE_FILE=$(detect_profile)

echo "[*] Using profile: $PROFILE_FILE"

# --- Add alias if not exists ---
if grep -Fxq "alias timestomp='$INSTALL_PATH'" "$PROFILE_FILE"; then
    echo "[*] Alias already exists in $PROFILE_FILE"
else
    echo "alias timestomp='$INSTALL_PATH'" >> "$PROFILE_FILE"
    echo "[*] Alias added to $PROFILE_FILE"
fi

echo "[*] Reloading shell profile..."
# shellcheck disable=SC1090
source "$PROFILE_FILE"

echo ""
echo "[+] Installation completed!"
echo "[+] You can now run:"
echo "    timestomp <args>"
