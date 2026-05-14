#!/usr/bin/env bash
set -euo pipefail

EVE_JSON="/var/log/suricata/eve.json"
DATA_DIR="${EVEBOX_DATA_DIR:-/tmp/evebox-suricata-data}"

echo "[1/3] Checking EveBox installation..."
if ! command -v evebox >/dev/null 2>&1; then
  echo "ERROR: evebox command was not found. Run ./scripts/05_install_evebox.sh for installation guidance." >&2
  exit 1
fi

echo "[2/3] Checking Suricata EVE JSON log..."
if ! sudo test -f "${EVE_JSON}"; then
  echo "WARNING: ${EVE_JSON} does not exist yet."
  echo "Start Suricata and generate traffic before expecting alerts in EveBox."
fi

cat <<INFO
[3/3] Starting EveBox in standalone SQLite mode.

Open the EveBox GUI in a browser:
  http://127.0.0.1:5636

Press Ctrl+C to stop EveBox.
INFO

mkdir -p "${DATA_DIR}"
sudo evebox server --sqlite --no-tls --data-directory "${DATA_DIR}" --input "${EVE_JSON}"
