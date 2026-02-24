# -----------------------------
# Install mpv + mpvpaper
# -----------------------------
echo "[+] Installing mpv and mpvpaper..."
sudo dnf install -y mpv mpvpaper

# -----------------------------
# Copy video to home (optional)
# -----------------------------
VIDEO_SRC="$SCRIPT_DIR/wallpaper.mp4"
VIDEO_DST="$HOME/Videos/wallpaper.mp4"
mkdir -p "$HOME/Videos"
cp -f "$VIDEO_SRC" "$VIDEO_DST"

# -----------------------------
# Detect primary monitor
# -----------------------------
PRIMARY_MONITOR=$(kscreen-doctor -o | awk '/enabled connected/{print $3; exit}')
echo "[+] Primary monitor detected: $PRIMARY_MONITOR"

# -----------------------------
# Create systemd service to start wallpaper on login
# -----------------------------
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

# -----------------------------
# Enable and start the service
# -----------------------------
systemctl --user daemon-reload
systemctl --user enable video-wallpaper
systemctl --user start video-wallpaper

echo "[+] Video wallpaper service installed and started!"
