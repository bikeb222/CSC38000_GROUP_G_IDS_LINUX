#!/usr/bin/env bash
set -euo pipefail

echo "[1/3] Checking for suricata-update..."
if ! command -v suricata-update >/dev/null 2>&1; then
  echo "ERROR: suricata-update was not found. Install Suricata first." >&2
  exit 1
fi

echo "[2/3] Downloading and updating ET Open rules through suricata-update..."
sudo suricata-update

echo "[3/3] Showing installed rule files..."
sudo ls -lah /var/lib/suricata/rules/

echo "Rule update complete."
