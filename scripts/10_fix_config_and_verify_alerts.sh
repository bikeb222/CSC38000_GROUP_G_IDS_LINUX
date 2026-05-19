#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
SURICATA_CONF="/etc/suricata/suricata.yaml"
LOCAL_RULES_SRC="${PROJECT_ROOT}/suricata/local.rules"
LOCAL_RULES_DST="/etc/suricata/rules/local.rules"
PCAP_DIR="${PCAP_DIR:-/tmp/suricata-pcap-verification}"
PCAP_FILE="${PCAP_DIR}/local-signature-test.pcap"
OUT_DIR="${PCAP_DIR}/suricata-output"
HTTP_PORT="8080"
HOME_NET_VALUE="[127.0.0.1, 192.168.0.0/16, 10.0.0.0/8, 172.16.0.0/12]"

echo "[1/8] Checking sudo access..."
sudo -v

echo "[2/8] Installing project local.rules..."
sudo mkdir -p /etc/suricata/rules
sudo install -m 0644 "${LOCAL_RULES_SRC}" "${LOCAL_RULES_DST}"

echo "[3/8] Backing up Suricata configuration..."
if ! sudo test -f "${SURICATA_CONF}.bak"; then
  sudo cp "${SURICATA_CONF}" "${SURICATA_CONF}.bak"
  echo "Created backup: ${SURICATA_CONF}.bak"
else
  TS="$(date +%Y%m%d-%H%M%S)"
  sudo cp "${SURICATA_CONF}" "${SURICATA_CONF}.verify-${TS}.bak"
  echo "Created timestamp backup: ${SURICATA_CONF}.verify-${TS}.bak"
fi

echo "[4/8] Setting HOME_NET for localhost and private lab networks..."
sudo perl -0pi -e 'BEGIN { $home_net = shift @ARGV } s/^([ \t]*HOME_NET:[ \t]*).*$/\1"$home_net"/m' "${HOME_NET_VALUE}" "${SURICATA_CONF}"

if ! sudo grep -Eq '^[[:space:]]*HOME_NET:[[:space:]]*"\[127\.0\.0\.1, 192\.168\.0\.0/16, 10\.0\.0\.0/8, 172\.16\.0\.0/12\]"[[:space:]]*$' "${SURICATA_CONF}"; then
  echo "ERROR: Failed to verify HOME_NET in ${SURICATA_CONF}." >&2
  echo "Expected value:" >&2
  echo "  HOME_NET: \"${HOME_NET_VALUE}\"" >&2
  echo "Current HOME_NET lines:" >&2
  sudo grep -nE 'HOME_NET' "${SURICATA_CONF}" >&2 || true
  exit 1
fi

echo "[5/8] Ensuring absolute local.rules path is loaded..."
if ! sudo grep -qE '^[[:space:]]*-[[:space:]]*/etc/suricata/rules/local\.rules[[:space:]]*$' "${SURICATA_CONF}"; then
  sudo perl -0pi -e 's/(^rule-files:\n(?:[ \t]+-[^\n]*\n)*)/$1  - \/etc\/suricata\/rules\/local.rules\n/m' "${SURICATA_CONF}"
fi

if ! sudo grep -qE '^[[:space:]]*-[[:space:]]*/etc/suricata/rules/local\.rules[[:space:]]*$' "${SURICATA_CONF}"; then
  echo "ERROR: Failed to verify that /etc/suricata/rules/local.rules is loaded in ${SURICATA_CONF}." >&2
  echo "Current rule-files section:" >&2
  sudo sed -n '/^rule-files:/,/^[^[:space:]-]/p' "${SURICATA_CONF}" >&2 || true
  exit 1
fi

echo "Current relevant Suricata settings:"
sudo grep -nE 'HOME_NET|default-rule-path|rule-files|/etc/suricata/rules/local\.rules|suricata\.rules' "${SURICATA_CONF}" || true

echo "[6/8] Testing Suricata configuration..."
sudo suricata -T -c "${SURICATA_CONF}" -v

echo "[7/8] Capturing safe local test traffic to PCAP..."
rm -rf "${PCAP_DIR}"
mkdir -p "${PCAP_DIR}" "${OUT_DIR}"

sudo tcpdump -i lo -w "${PCAP_FILE}" >"${PCAP_DIR}/tcpdump.log" 2>&1 &
TCPDUMP_PID="$!"
sleep 2

ping -c 4 127.0.0.1 >"${PCAP_DIR}/ping.log" 2>&1 || true

python3 -m http.server "${HTTP_PORT}" --bind 127.0.0.1 >"${PCAP_DIR}/http.log" 2>&1 &
HTTP_PID="$!"
sleep 1
curl -sS "http://127.0.0.1:${HTTP_PORT}/test-attack" >"${PCAP_DIR}/curl.log" 2>&1 || true
kill "${HTTP_PID}" >/dev/null 2>&1 || true

sudo -n nmap -sS -p 1-200 127.0.0.1 >"${PCAP_DIR}/nmap.log" 2>&1 || true
timeout 5 ssh -o BatchMode=yes -o StrictHostKeyChecking=no -o ConnectTimeout=3 localhost true >"${PCAP_DIR}/ssh.log" 2>&1 || true
timeout 5 bash -c 'printf "\n" | telnet localhost 23' >"${PCAP_DIR}/telnet.log" 2>&1 || true

sleep 2
sudo kill -INT "${TCPDUMP_PID}" >/dev/null 2>&1 || true
sleep 2

echo "[8/8] Running Suricata in PCAP/offline mode and collecting LOCAL alerts..."
sudo suricata -c "${SURICATA_CONF}" -r "${PCAP_FILE}" -l "${OUT_DIR}" -k none

echo
echo "LOCAL alerts in fast.log:"
sudo grep "LOCAL" "${OUT_DIR}/fast.log" || echo "No LOCAL alerts found in fast.log."

echo
echo "LOCAL alerts in eve.json:"
if sudo test -f "${OUT_DIR}/eve.json"; then
  sudo jq 'select(.event_type=="alert" and (.alert.signature | contains("LOCAL"))) | {timestamp, src_ip, src_port, dest_ip, dest_port, proto, signature: .alert.signature, sid: .alert.signature_id}' "${OUT_DIR}/eve.json" || true
else
  echo "No eve.json file found."
fi

echo
echo "Verification complete."
echo "PCAP file: ${PCAP_FILE}"
echo "Suricata output directory: ${OUT_DIR}"
