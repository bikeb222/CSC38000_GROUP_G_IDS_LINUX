#!/usr/bin/env bash
set -euo pipefail

HTTP_PORT="8080"
SERVER_PID=""
HTTP_LOG="/tmp/suricata-test-http.log"

cleanup() {
  if [[ -n "${SERVER_PID}" ]] && kill -0 "${SERVER_PID}" >/dev/null 2>&1; then
    echo "Stopping temporary HTTP server..."
    kill "${SERVER_PID}" >/dev/null 2>&1 || true
  fi
}
trap cleanup EXIT

echo "[1/5] ICMP test: sending pings to localhost..."
ping -c 4 127.0.0.1 || true

echo "[2/5] HTTP test: starting temporary Python HTTP server on 127.0.0.1:${HTTP_PORT}..."
python3 -m http.server "${HTTP_PORT}" --bind 127.0.0.1 >"${HTTP_LOG}" 2>&1 &
SERVER_PID="$!"
sleep 2

echo "Requesting URI containing the custom test string..."
curl -sS "http://127.0.0.1:${HTTP_PORT}/test-attack" >/dev/null || true

echo "[3/5] Nmap SYN scan test against localhost..."
if command -v nmap >/dev/null 2>&1; then
  if [[ "${EUID}" -eq 0 ]]; then
    nmap -sS 127.0.0.1 || true
  else
    sudo nmap -sS 127.0.0.1 || true
  fi
else
  echo "nmap is not installed. Run ./scripts/01_install_dependencies.sh first."
fi

echo "[4/5] SSH connection attempt test..."
timeout 5 ssh -o BatchMode=yes -o StrictHostKeyChecking=no -o ConnectTimeout=3 localhost true || true

echo "[5/5] Optional Telnet connection attempt test..."
if command -v telnet >/dev/null 2>&1; then
  timeout 5 bash -c 'printf "\n" | telnet localhost 23' || true
else
  echo "telnet is not installed. This optional test was skipped."
fi

cat <<'INFO'
Traffic generation complete.

Check Suricata fast alerts:
  sudo tail -f /var/log/suricata/fast.log

Check Suricata EVE JSON alerts:
  sudo tail -f /var/log/suricata/eve.json | jq 'select(.event_type=="alert")'
INFO
