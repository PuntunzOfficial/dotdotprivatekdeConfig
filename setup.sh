#!/usr/bin/env bash

set -e

echo "==============================="
echo " Terminal Setup Installer"
echo "==============================="

# Get script directory (so it works from anywhere)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

LOGO="$SCRIPT_DIR/logo.png"
BASHRC="$SCRIPT_DIR/.bashrc"
FASTFETCH_CONFIG="$SCRIPT_DIR/config.jsonc"

# -----------------------------
# Install / Update fastfetch
# -----------------------------
echo "[+] Installing / Updating fastfetch..."
sudo dnf install -y fastfetch

# -----------------------------
# Copy logo.png to Documents
# -----------------------------
echo "[+] Installing logo.png..."
mkdir -p "$HOME/Documents"
cp -f "$LOGO" "$HOME/Documents/logo.png"

# -----------------------------
# Backup and replace .bashrc
# -----------------------------
if [ -f "$HOME/.bashrc" ]; then
    echo "[+] Backing up existing .bashrc..."
    mv -f "$HOME/.bashrc" "$HOME/.bashrc(copy)"
fi

echo "[+] Installing new .bashrc..."
cp "$BASHRC" "$HOME/.bashrc"

# -----------------------------
# Backup and replace fastfetch config
# -----------------------------
mkdir -p "$HOME/.fastfetch"

if [ -f "$HOME/.fastfetch/config.jsonc" ]; then
    echo "[+] Backing up existing fastfetch config..."
    mv -f "$HOME/.fastfetch/config.jsonc" "$HOME/.fastfetch/config.jsonc(copy)"
fi

echo "[+] Installing new fastfetch config..."
cp "$FASTFETCH_CONFIG" "$HOME/.fastfetch/config.jsonc"

echo ""
echo "================================="
echo " Installation Complete!"
echo "================================="
echo "Restart your terminal or run:"
echo "source ~/.bashrc"
