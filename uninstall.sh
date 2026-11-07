#!/usr/bin/env bash
set -e

if [ "$EUID" -ne 0 ]; then
    echo "Privilegios de superusuario requeridos. Solicitando sudo..."
    exec sudo "$0" "$@"
fi

echo "=== Desinstalando optimizaciones de Chrome y zram ==="

# 1. Remove Chrome flags and wrapper
rm -f /etc/default/google-chrome-flags
rm -f /usr/local/bin/google-chrome-stable
rm -f /usr/local/bin/google-chrome
USER_DESKTOP="/home/${SUDO_USER:-$USER}/.local/share/applications/google-chrome.desktop"
rm -f "$USER_DESKTOP"
echo "[OK] Wrapper y flags de Chrome eliminados."

# 2. Remove Chrome Enterprise Policies
rm -f /etc/opt/chrome/policies/managed/t2_performance.json
rm -f /etc/chromium/policies/managed/t2_performance.json
echo "[OK] Políticas administradas eliminadas."

# 3. Restore default sysctl and zram if desired
rm -f /etc/sysctl.d/99-t2-zram-performance.conf
sysctl --system >/dev/null 2>&1 || true

read -p "¿Deseas también desinstalar zram-tools y volver al swap de disco estándar? (s/N): " -r RESP
if [[ "$RESP" =~ ^[sS]$ ]]; then
    systemctl stop zramswap.service || true
    systemctl disable zramswap.service || true
    apt-get remove -y zram-tools || true
    echo "[OK] zram-tools desinstalado."
fi

echo "=== Desinstalación completada. Reinicia Chrome para aplicar ==="

