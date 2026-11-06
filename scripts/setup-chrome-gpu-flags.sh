#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FLAGS_SRC="$SCRIPT_DIR/google-chrome-flags.conf"
FLAGS_DEST="/etc/default/google-chrome-flags"
WRAPPER_BIN="/usr/local/bin/google-chrome-stable"

echo "=== Configuring Chrome GPU Hardware Acceleration & Wayland Zero-Copy ==="

# 1. Install flags configuration file
install -m 644 "$FLAGS_SRC" "$FLAGS_DEST"
echo "[OK] Installed hardware flags to $FLAGS_DEST"

# 2. Install wrapper binary in /usr/local/bin
cat << 'EOF' > "$WRAPPER_BIN"
#!/usr/bin/env bash
# T2 MacBook Pro 16,1 Hardware-Accelerated Chrome Launcher
# Offloads 3072x1920 Retina rendering to AMD Radeon Pro 5500M with Wayland Zero-Copy & VA-API

FLAGS_FILE="/etc/default/google-chrome-flags"
FLAGS=()

if [ -f "$FLAGS_FILE" ]; then
    while IFS= read -r line || [ -n "$line" ]; do
        line="$(echo "$line" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
        [[ -z "$line" || "$line" =~ ^# ]] && continue
        FLAGS+=("$line")
    done < "$FLAGS_FILE"
fi

exec /opt/google/chrome/chrome "${FLAGS[@]}" "$@"
EOF

chmod 755 "$WRAPPER_BIN"
ln -sf "$WRAPPER_BIN" /usr/local/bin/google-chrome
echo "[OK] Installed wrapper binary to $WRAPPER_BIN and symlink /usr/local/bin/google-chrome"

# 3. Update User Desktop Entry if running under a user session
USER_DESKTOP="/home/${SUDO_USER:-$USER}/.local/share/applications/google-chrome.desktop"
if [ -d "/home/${SUDO_USER:-$USER}/.local/share/applications" ]; then
    cp /usr/share/applications/google-chrome.desktop "$USER_DESKTOP" 2>/dev/null || true
    if [ -f "$USER_DESKTOP" ]; then
        sed -i 's|Exec=/usr/bin/google-chrome-stable|Exec=/usr/local/bin/google-chrome-stable|g' "$USER_DESKTOP"
        chown "${SUDO_USER:-$USER}:${SUDO_USER:-$USER}" "$USER_DESKTOP"
        echo "[OK] Updated user desktop entry at $USER_DESKTOP"
    fi
fi

