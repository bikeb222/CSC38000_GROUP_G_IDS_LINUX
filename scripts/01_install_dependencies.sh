#!/usr/bin/env bash
set -euo pipefail

echo "[1/3] Updating package indexes..."
sudo apt update

echo "[2/3] Installing base tools used by this Suricata IDS project..."
sudo apt install -y \
  software-properties-common \
  curl \
  wget \
  jq \
  net-tools \
  iproute2 \
  nano \
  unzip \
  ca-certificates \
  gnupg \
  lsb-release \
  nmap \
  python3 \
  openssh-client \
  telnet \
  tcpdump

echo "[3/3] Dependency installation complete."
echo "Next step: run ./scripts/02_install_suricata.sh"
