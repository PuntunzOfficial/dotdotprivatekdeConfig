#!/usr/bin/env bash

set -e

echo "======================================="
echo " Fedora KDE Auto Setup (Wayland)"
echo "======================================="

# -----------------------------
# Detect session type
# -----------------------------
if [ "$XDG_SESSION_TYPE" != "wayland" ]; then
    echo "This script is made for Wayland."
    echo "Current session: $XDG_SESSION_TYPE"
    exit 1
fi

# -----------------------------
# Get script directory
# -----------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VIDEO="$SCRIPT_DIR/wallpaper.mp4"
FASTFETCH_CONFIG="$SCRIPT_DIR/fastfetch-config.jsonc"

# -----------------------------
# Update + Install dependencies
# -----------------------------
echo "[+] Installing dependencies..."
sudo dnf install -y mpv mpvpaper fastfetch konsole

# -----------------------------
# Detect primary monitor
# -----------------------------
echo "[+] Detecting monitor..."
MONITOR=$(kscreen-doctor -o | awk '/enabled connected/{print $3; exit}')

if [ -z "$MONITOR" ]; then
    echo "Could not detect monitor."
    exit 1
fi

echo "Detected monitor: $MONITOR"

# -----------------------------
# Stop existing wallpaper
# -----------------------------
pkill mpvpaper 2>/dev/null || true

# -----------------------------
# Create systemd user service
# -----------------------------
echo "[+] Creating wallpaper service..."

mkdir -p ~/.config/systemd/user

cat > ~/.config/systemd/user/video-wallpaper.service <<EOF
[Unit]
Description=Video Wallpaper (Wayland)

[Service]
ExecStart=/usr/bin/mpvpaper -o "--loop --volume=40" $MONITOR $VIDEO
Restart=on-failure

[Install]
WantedBy=default.target
EOF

systemctl --user daemon-reload
systemctl --user enable video-wallpaper
systemctl --user start video-wallpaper

# -----------------------------
# Setup fastfetch
# -----------------------------
echo "[+] Configuring fastfetch..."

mkdir -p ~/.config/fastfetch
cp "$FASTFETCH_CONFIG" ~/.config/fastfetch/config.jsonc

# -----------------------------
# Auto-run fastfetch in Konsole
# -----------------------------
if ! grep -q "fastfetch" ~/.bashrc; then
    echo "fastfetch" >> ~/.bashrc
fi

echo ""
echo "======================================="
echo " Setup Complete!"
echo "======================================="
