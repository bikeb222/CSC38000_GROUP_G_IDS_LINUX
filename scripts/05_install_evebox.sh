#!/usr/bin/env bash
set -euo pipefail

EVEBOX_KEYRING="/etc/apt/keyrings/evebox.asc"
EVEBOX_SOURCE_LIST="/etc/apt/sources.list.d/evebox.list"
EVEBOX_REPO_LINE="deb [signed-by=${EVEBOX_KEYRING}] https://evebox.org/files/debian stable main"

echo "[1/5] Checking whether the evebox command is already installed..."
if command -v evebox >/dev/null 2>&1; then
  echo "EveBox is already available:"
  evebox --version || true
  exit 0
fi

echo "[2/5] Installing APT support packages..."
sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg

echo "[3/5] Adding the official EveBox stable APT repository..."
sudo install -d -m 0755 /etc/apt/keyrings
if ! curl -fsSL https://evebox.org/files/evebox.asc | sudo tee "${EVEBOX_KEYRING}" >/dev/null; then
  cat <<EOF >&2
ERROR: Failed to download the EveBox repository signing key.

Manual fallback:
  Open https://evebox.org/docs/install/debian/ and follow the Debian/Ubuntu
  stable repository instructions.
EOF
  exit 1
fi
sudo chmod 0644 "${EVEBOX_KEYRING}"
echo "${EVEBOX_REPO_LINE}" | sudo tee "${EVEBOX_SOURCE_LIST}" >/dev/null

echo "[4/5] Updating package indexes with the EveBox repository..."
sudo apt-get update

echo "[5/5] Installing EveBox from the official APT repository..."
if ! sudo apt-get install -y evebox; then
  cat <<EOF >&2
ERROR: Failed to install EveBox from the official APT repository.

Manual fallback:
  Open https://evebox.org/docs/install/debian/ and follow the Debian/Ubuntu
  stable repository instructions.
EOF
  exit 1
fi

echo "EveBox installation result:"
evebox --version
