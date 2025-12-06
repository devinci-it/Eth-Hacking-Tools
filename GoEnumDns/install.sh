#!/usr/bin/env bash

# Determine the absolute path of the directory this script lives in
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Full path to main.sh
TARGET="$SCRIPT_DIR/main.sh"

# Ensure main.sh exists
if [[ ! -f "$TARGET" ]]; then
    echo "[ERROR] main.sh not found at: $TARGET"
    exit 1
fi

# Ensure the install.sh and main.sh are executable
chmod +x "$SCRIPT_DIR/install.sh"
chmod +x "$TARGET"

echo "[+] Ensured files are executable: $SCRIPT_DIR/install.sh, $TARGET"

echo "[+] Installing alias 'dnsenum' pointing to:"
echo "    $TARGET"

# Add alias to ~/.bashrc (or ~/.zshrc if user uses zsh)
SHELL_RC="$HOME/.bashrc"

if [[ -n "$ZSH_VERSION" ]]; then
    SHELL_RC="$HOME/.zshrc"
fi

# Add alias if not already present
if ! grep -q "alias dnsenum=" "$SHELL_RC"; then
    echo "alias dnsenum=\"$TARGET\"" >> "$SHELL_RC"
    echo "[+] Alias added to $SHELL_RC"
else
    echo "[i] Alias already exists in $SHELL_RC"
fi

echo
echo "[*] Installation complete!"
echo ">>> Run 'source $SHELL_RC' or open a new terminal to use 'dnsenum'"
