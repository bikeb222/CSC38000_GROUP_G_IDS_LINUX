#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

echo "Suricata + EveBox WSL IDS deployment"
echo "Project root: ${PROJECT_ROOT}"
echo

echo "[1/7] Checking sudo access once at the beginning..."
sudo -v

echo "[2/7] Installing base dependencies..."
"${SCRIPT_DIR}/01_install_dependencies.sh"

echo "[3/7] Installing Suricata if needed..."
if command -v suricata >/dev/null 2>&1; then
  echo "Suricata already installed:"
  suricata --build-info | sed -n '1,3p'
else
  "${SCRIPT_DIR}/02_install_suricata.sh"
fi

echo "[4/7] Updating ET Open rules..."
"${SCRIPT_DIR}/04_update_rules.sh"

echo "[5/7] Installing EveBox if needed..."
"${SCRIPT_DIR}/05_install_evebox.sh"

echo "[6/7] Configuring Suricata and verifying custom signatures with PCAP mode..."
"${SCRIPT_DIR}/10_fix_config_and_verify_alerts.sh"

echo "[7/7] Starting EveBox with the verified alert file..."
"${SCRIPT_DIR}/11_start_evebox_demo.sh"

cat <<'INFO'

Deployment complete.

Open EveBox in a browser:
  http://127.0.0.1:5636

Useful evidence files:
  /tmp/suricata-pcap-verification/local-signature-test.pcap
  /tmp/suricata-pcap-verification/suricata-output/fast.log
  /tmp/suricata-pcap-verification/suricata-output/eve.json

To rerun only the alert verification:
  ./scripts/10_fix_config_and_verify_alerts.sh

To restart only EveBox:
  ./scripts/11_start_evebox_demo.sh
INFO
