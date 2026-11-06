#!/usr/bin/env bash

echo "=========================================================="
echo "    T2 MacBook Pro 16,1 - Chrome & Memory Benchmark       "
echo "=========================================================="
date "+Timestamp: %Y-%m-%d %H:%M:%S"
echo ""

echo "--- 1. Chrome Memory & Process Footprint ---"
CHROME_COUNT=$(pgrep -f "/opt/google/chrome/chrome" | wc -l)
echo "Active Chrome Processes: $CHROME_COUNT"
ps aux | grep "/opt/google/chrome/chrome" | awk '{sum+=$6} END {printf "Chrome Total RSS RAM: %.2f MB (%.2f GB)\n", sum/1024, sum/1024/1024}'

echo ""
echo "--- 2. System RAM & Swap Architecture ---"
free -h
echo ""
swapon --show

echo ""
echo "--- 3. zram Compression Metrics ---"
if command -v zramctl >/dev/null 2>&1; then
    zramctl
else
    echo "zramctl not available"
fi

echo ""
echo "--- 4. Active Chrome GPU Process ---"
GPU_PROC=$(ps aux | grep -E "chrome.*--type=gpu-process" | head -n 1)
if [ -n "$GPU_PROC" ]; then
    echo "$GPU_PROC" | awk '{printf "PID: %s | CPU: %s%% | MEM: %s%% | RSS: %.1f MB\n", $2, $3, $4, $6/1024}'
    echo "Wayland / Flags:"
    echo "$GPU_PROC" | grep -o -E "\-\-ozone\-platform[^\ ]*|\-\-render\-node[^\ ]*|\-\-enable\-features[^\ ]*" | tr " " "\n"
else
    echo "No GPU process found running."
fi

echo ""
echo "--- 5. Chrome Managed Policies ---"
if [ -f "/etc/opt/chrome/policies/managed/t2_performance.json" ]; then
    cat /etc/opt/chrome/policies/managed/t2_performance.json
else
    echo "No managed policy file in /etc/opt/chrome/policies/managed/"
fi
echo "=========================================================="

