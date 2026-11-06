#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"
POLICY_SRC="$REPO_DIR/policies/t2_performance.json"

echo "=== Configuring Chrome Native Memory Saver & Tab Discarding Policies ==="

# 1. Chrome Managed Policies Directory
mkdir -p /etc/opt/chrome/policies/managed
mkdir -p /etc/chromium/policies/managed

# 2. Deploy Enterprise Performance Policy
install -m 644 "$POLICY_SRC" /etc/opt/chrome/policies/managed/t2_performance.json
install -m 644 "$POLICY_SRC" /etc/chromium/policies/managed/t2_performance.json

echo "[OK] Deployed HighEfficiencyMode (Memory Saver Aggressive) to /etc/opt/chrome/policies/managed/"

