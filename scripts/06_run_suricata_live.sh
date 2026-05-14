#!/usr/bin/env bash
set -euo pipefail

SURICATA_CONF="/etc/suricata/suricata.yaml"
IFACE="${1:-}"

echo "[1/3] Selecting network interface for live monitoring..."
if [[ -z "${IFACE}" ]]; then
  IFACE="$(ip route | awk '/default/ {print $5; exit}')"
fi

if [[ -z "${IFACE}" ]]; then
  IFACE="eth0"
fi

echo "Selected interface: ${IFACE}"

echo "[2/3] Checking Suricata configuration path..."
if ! sudo test -f "${SURICATA_CONF}"; then
  echo "ERROR: ${SURICATA_CONF} does not exist. Install and configure Suricata first." >&2
  exit 1
fi

echo "[3/3] Starting Suricata in live IDS mode..."
echo "Press Ctrl+C to stop Suricata."
sudo suricata -c "${SURICATA_CONF}" -i "${IFACE}"
