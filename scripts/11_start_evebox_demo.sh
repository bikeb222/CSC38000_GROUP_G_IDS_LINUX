#!/usr/bin/env bash
set -euo pipefail

EVE_JSON="${1:-/tmp/suricata-pcap-verification/suricata-output/eve.json}"
DATA_DIR="${EVEBOX_DATA_DIR:-/tmp/evebox-suricata-demo-data}"
LOG_FILE="${EVEBOX_LOG_FILE:-/tmp/evebox-suricata-demo.log}"

echo "[1/4] Checking EveBox installation..."
if ! command -v evebox >/dev/null 2>&1; then
  echo "ERROR: evebox command was not found. Run ./scripts/05_install_evebox.sh first." >&2
  exit 1
fi

echo "[2/4] Checking EVE JSON input..."
if [[ ! -r "${EVE_JSON}" ]]; then
  echo "ERROR: EVE JSON file is not readable: ${EVE_JSON}" >&2
  echo "Run ./scripts/10_fix_config_and_verify_alerts.sh first." >&2
  exit 1
fi

echo "[3/4] Restarting EveBox demo server..."
pkill -x evebox >/dev/null 2>&1 || true
rm -rf "${DATA_DIR}"
mkdir -p "${DATA_DIR}"

setsid evebox server \
  --sqlite \
  --no-auth \
  --no-tls \
  --data-directory "${DATA_DIR}" \
  --input "${EVE_JSON}" \
  >"${LOG_FILE}" 2>&1 < /dev/null &

sleep 4

if ! pgrep -x evebox >/dev/null 2>&1; then
  echo "ERROR: EveBox did not stay running. Log output:" >&2
  sed -n '1,160p' "${LOG_FILE}" >&2 || true
  exit 1
fi

echo "[4/4] Confirming EveBox HTTP endpoint..."
if curl -fsS -I http://127.0.0.1:5636/ >/dev/null; then
  echo "EveBox is running: http://127.0.0.1:5636"
else
  echo "WARNING: EveBox process is running, but the HTTP check failed."
  echo "Check log: ${LOG_FILE}"
fi

echo "EveBox input file: ${EVE_JSON}"
echo "EveBox data directory: ${DATA_DIR}"
