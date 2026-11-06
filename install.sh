#!/usr/bin/env bash
set -e

# Ensure running as root
if [ "$EUID" -ne 0 ]; then
    echo "Privilegios de superusuario requeridos. Solicitando sudo (Touch ID o contraseña)..."
    exec sudo "$0" "$@"
fi

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPTS_DIR="$REPO_DIR/scripts"

echo "================================================================="
echo "   🚀 T2 MacBook Pro 16,1 (A2141) - Chrome & GPU Optimizer      "
echo "================================================================="

# 1. zram Memory & Kernel Optimization
echo ""
bash "$SCRIPTS_DIR/setup-zram-memory.sh"

# 2. Chrome Enterprise Managed Policies (HighEfficiencyMode Tab Discarding)
echo ""
bash "$SCRIPTS_DIR/setup-chrome-policies.sh"

# 3. GPU Hardware Acceleration & Wayland Zero-Copy Flags
echo ""
bash "$SCRIPTS_DIR/setup-chrome-gpu-flags.sh"

# 4. Update Google Chrome to latest repository version if available
echo ""
echo "=== Checking Chrome Update in Official Repository ==="
DEBIAN_FRONTEND=noninteractive apt-get update -qq -o Dir::Etc::sourcelist="sources.list.d/google-chrome.sources" 2>/dev/null || true
DEBIAN_FRONTEND=noninteractive apt-get --only-upgrade install -y google-chrome-stable || true

# 5. Run Live Benchmark
echo ""
bash "$SCRIPTS_DIR/benchmark-chrome.sh"

echo ""
echo "================================================================="
echo "✅ Optimización completada con éxito."
echo "Para activar los nuevos flags de GPU y la política de ahorro:"
echo "Cierra y vuelve a abrir Google Chrome cuando estés listo."
echo "================================================================="

