#!/usr/bin/env bash
set -e

echo "========================================="
echo " Fedora KDE Terminal + Video Wallpaper Installer"
echo "========================================="

# -----------------------------
# Install Git if missing
# -----------------------------
echo "[+] Installing Git..."
sudo dnf install -y git

# -----------------------------
# Get script directory
# -----------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# -----------------------------
# Terminal Setup
# -----------------------------
LOGO="$SCRIPT_DIR/logo.png"
BASHRC_SOURCE="$SCRIPT_DIR/bashrc"
FASTFETCH_CONFIG="$SCRIPT_DIR/config.jsonc"

# Install/update fastfetch
echo "[+] Installing / Updating fastfetch..."
sudo dnf install -y fastfetch

# Copy logo
echo "[+] Installing logo.png..."
mkdir -p "$HOME/Documents"
cp -f "$LOGO" "$HOME/Documents/logo.png"

# Backup and install .bashrc
if [ -f "$HOME/.bashrc" ]; then
    echo "[+] Backing up existing .bashrc..."
    mv -f "$HOME/.bashrc" "$HOME/.bashrc(copy)"
fi
echo "[+] Installing new .bashrc..."
cp "$BASHRC_SOURCE" "$HOME/.bashrc"

# Backup and install fastfetch config
CONFIG_DIR="$HOME/.config/fastfetch"
mkdir -p "$CONFIG_DIR"
if [ -f "$CONFIG_DIR/config.jsonc" ]; then
    echo "[+] Backing up existing fastfetch config..."
    mv -f "$CONFIG_DIR/config.jsonc" "$CONFIG_DIR/config.jsonc(copy)"
fi
echo "[+] Installing new fastfetch config..."
cp "$FASTFETCH_CONFIG" "$CONFIG_DIR/config.jsonc"
sed -i "s|\$HOME|$HOME|g" "$CONFIG_DIR/config.jsonc"

# Add fastfetch to bashrc if not already there
if ! grep -q "fastfetch" "$HOME/.bashrc"; then
    echo "fastfetch" >> "$HOME/.bashrc"
    echo "[+] Added fastfetch to .bashrc"
fi

# -----------------------------
# Video Wallpaper Setup
# -----------------------------
echo "[+] Installing mpv and mpvpaper..."
sudo dnf install -y mpv mpvpaper

VIDEO_SRC="$SCRIPT_DIR/wallpaper.mp4"
VIDEO_DST="$HOME/Videos/wallpaper.mp4"
mkdir -p "$HOME/Videos"
cp -f "$VIDEO_SRC" "$VIDEO_DST"

# Detect primary monitor
PRIMARY_MONITOR=$(kscreen-doctor -o | awk '/enabled connected/{print $3; exit}')
echo "[+] Primary monitor detected: $PRIMARY_MONITOR"

# Create systemd user service
SERVICE_DIR="$HOME/.config/systemd/user"
mkdir -p "$SERVICE_DIR"

cat > "$SERVICE_DIR/video-wallpaper.service" <<EOF
[Unit]
Description=Video Wallpaper (Wayland)

[Service]
ExecStart=/usr/bin/mpvpaper -o "--loop --volume=50" $PRIMARY_MONITOR $VIDEO_DST
Restart=on-failure

[Install]
WantedBy=default.target
EOF

# Enable and start the service
systemctl --user daemon-reload
systemctl --user enable video-wallpaper
systemctl --user start video-wallpaper

echo ""
echo "================================="
echo " Installation Complete!"
echo "================================="
echo "Restart your terminal or run:"
echo "source ~/.bashrc"
echo "Your video wallpaper with audio should now be running!"
