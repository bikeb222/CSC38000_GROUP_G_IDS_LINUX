#!/usr/bin/env bash
set -euo pipefail

echo "[1/4] Ensuring add-apt-repository is available..."
if ! command -v add-apt-repository >/dev/null 2>&1; then
  sudo apt update
  sudo apt install -y software-properties-common
fi

echo "[2/4] Adding the official OISF Suricata stable PPA..."
sudo add-apt-repository -y ppa:oisf/suricata-stable

echo "[3/4] Installing Suricata..."
sudo apt update
sudo apt install -y suricata

echo "[4/4] Displaying Suricata build information..."
suricata --build-info

echo "Suricata installation complete."
echo "Next step: run ./scripts/03_configure_suricata.sh"
