#!/usr/bin/env bash

set -e

echo "==============================="
echo " Terminal Setup Installer"
echo "==============================="

# -----------------------------
# Ensure git is installed
# -----------------------------
echo "[+] Installing Git if missing..."
sudo dnf install -y git
sudo dnf install -y qt5-qttools

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

LOGO="$SCRIPT_DIR/logo.png"
BASHRC_SOURCE="$SCRIPT_DIR/bashrc"
FASTFETCH_CONFIG="$SCRIPT_DIR/config.jsonc"

# -----------------------------
# Install / Update fastfetch
# -----------------------------
echo "[+] Installing / Updating fastfetch..."
sudo dnf install -y fastfetch
sudo dnf install -y mpv

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
cp "$BASHRC_SOURCE" "$HOME/.bashrc"

# -----------------------------
# Backup and replace fastfetch config
# -----------------------------
CONFIG_DIR="$HOME/.config/fastfetch"
mkdir -p "$CONFIG_DIR"

if [ -f "$CONFIG_DIR/config.jsonc" ]; then
    echo "[+] Backing up existing fastfetch config..."
    mv -f "$CONFIG_DIR/config.jsonc" "$CONFIG_DIR/config.jsonc(copy)"
fi

echo "[+] Installing new fastfetch config..."
cp "$FASTFETCH_CONFIG" "$CONFIG_DIR/config.jsonc"

# Replace $HOME placeholder with actual home directory
sed -i "s|\$HOME|$HOME|g" "$CONFIG_DIR/config.jsonc"

# -----------------------------
# Add fastfetch to .bashrc if not already there
# -----------------------------
if ! grep -q "fastfetch" "$HOME/.bashrc"; then
    echo "fastfetch" >> "$HOME/.bashrc"
    echo "[+] Added fastfetch to .bashrc"
fi

echo ""
echo "================================="
echo " Installation Complete!"
echo "================================="
echo "Restart your terminal or run:"
echo "source ~/.bashrc"

# -----------------------------
# Set KDE Plasma wallpaper via qdbus variant
# -----------------------------
WALLPAPER="$SCRIPT_DIR/wall.png"
if [ -f "$WALLPAPER" ]; then
    # Find which qdbus binary exists
    if command -v qdbus-qt5 >/dev/null 2>&1; then
        QDBUS_CMD="qdbus-qt5"
    elif command -v qdbus6 >/dev/null 2>&1; then
        QDBUS_CMD="qdbus6"
    else
        echo "[!] No qdbus CLI tool found (qdbus-qt5 or qdbus6 required)"
        exit 1
    fi

    echo "[+] Setting KDE Plasma wallpaper using $QDBUS_CMD"
    "$QDBUS_CMD" org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "
var allDesktops = desktops();
for (i=0; i<allDesktops.length; i++) {
    d = allDesktops[i];
    d.wallpaperPlugin = 'org.kde.image';
    d.currentConfigGroup = Array('Wallpaper','org.kde.image','General');
    d.writeConfig('Image', 'file://$WALLPAPER');
}"
else
    echo "[!] Wallpaper file not found: $WALLPAPER"
fi



# Terminal command varies depending on your terminal emulator
# Adjust "konsole" to "gnome-terminal", "alacritty", or "kitty" if needed

# 1. Open an empty terminal
konsole --new-tab &


konsole --new-tab -e bash -c "mpv --vo=tct '$SCRIPT_DIR/yourvideo.mp4'; exec bash" &
#this option is good, opens new window
#konsole --hold --separate -e bash -c "mpv --no-config --vo=tct --really-quiet --loop '$SCRIPT_DIR/wallpaper.mp4'; exec bash"

#normal same window
#mpv --no-config --vo=tct --really-quiet --loop "$SCRIPT_DIR/wallpaper.mp4"

# 2. Open a terminal running mpv with ASCII video no video just audio
#mpv --no-config --vo=tct --really-quiet --loop "$SCRIPT_DIR/wallpaper.mp4" </dev/null >/dev/null 2>&1 &
