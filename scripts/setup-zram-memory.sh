#!/usr/bin/env bash
set -e

echo "=== Configuring zram (High-Speed In-Memory Compressed Swap) ==="

# 1. Install zram-tools if not present
if ! dpkg -s zram-tools >/dev/null 2>&1; then
    echo "Installing zram-tools..."
    DEBIAN_FRONTEND=noninteractive apt-get update -qq
    DEBIAN_FRONTEND=noninteractive apt-get install -y zram-tools
fi

# 2. Configure zramswap for 8GB (50% of 16GB RAM) with zstd compression
cat << 'EOF' > /etc/default/zramswap
# Compression algorithm (zstd provides optimal compression ratio & CPU efficiency)
ALGO=zstd

# Allocate 50% of total physical RAM (approx. 8 GB compressed swap)
PERCENT=50

# Priority higher than disk swapfile (disk is -1 or 0, zram is 100)
PRIORITY=100
EOF

# 3. Optimize Linux Kernel Virtual Memory sysctl for zram
cat << 'EOF' > /etc/sysctl.d/99-t2-zram-performance.conf
# Aggressively swap cold idle anonymous pages into fast zstd RAM compressed cache
vm.swappiness=180

# Keep filesystem dentries and inodes in cache for snappy system responsiveness
vm.vfs_cache_pressure=50

# Disable multi-page sequential disk read clustering since zram has 0 seek latency
vm.page-cluster=0
EOF

# 4. Apply sysctl & restart zram service
sysctl -p /etc/sysctl.d/99-t2-zram-performance.conf >/dev/null
systemctl restart zramswap.service || service zramswap restart

echo "[OK] zram active. Current Swap Allocation:"
swapon --show

