#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
LOCAL_RULES="${PROJECT_ROOT}/suricata/local.rules"
SURICATA_CONF="/etc/suricata/suricata.yaml"
SURICATA_RULE_DIR="/etc/suricata/rules"
SURICATA_LOCAL_RULES="${SURICATA_RULE_DIR}/local.rules"

echo "[1/5] Checking that Suricata is installed..."
if ! command -v suricata >/dev/null 2>&1; then
  echo "ERROR: Suricata is not installed. Run ./scripts/02_install_suricata.sh first." >&2
  exit 1
fi

if [[ ! -f "${LOCAL_RULES}" ]]; then
  echo "ERROR: Local rule file not found: ${LOCAL_RULES}" >&2
  exit 1
fi

echo "[2/5] Installing custom local.rules into ${SURICATA_RULE_DIR}..."
sudo mkdir -p "${SURICATA_RULE_DIR}"

if sudo test -f "${SURICATA_LOCAL_RULES}"; then
  BACKUP_RULES="${SURICATA_LOCAL_RULES}.bak.$(date +%Y%m%d-%H%M%S)"
  echo "Existing local.rules found. Creating backup at ${BACKUP_RULES}"
  sudo cp "${SURICATA_LOCAL_RULES}" "${BACKUP_RULES}"
fi

sudo install -m 0644 "${LOCAL_RULES}" "${SURICATA_LOCAL_RULES}"

echo "[3/5] Checking Suricata configuration file..."
if ! sudo test -f "${SURICATA_CONF}"; then
  echo "ERROR: ${SURICATA_CONF} does not exist. Check your Suricata installation." >&2
  exit 1
fi

if ! sudo test -f "${SURICATA_CONF}.bak"; then
  echo "Creating one-time backup: ${SURICATA_CONF}.bak"
  sudo cp "${SURICATA_CONF}" "${SURICATA_CONF}.bak"
else
  echo "Backup already exists: ${SURICATA_CONF}.bak"
fi

cat <<'INSTRUCTIONS'
[4/5] Manual configuration checks required in /etc/suricata/suricata.yaml

Open the file:
  sudo nano /etc/suricata/suricata.yaml

Verify these settings:
  1. HOME_NET includes localhost and private lab networks.
  2. rule-files includes local.rules.
  3. eve-log is enabled and writes to /var/log/suricata/eve.json.

Recommended HOME_NET example:
  HOME_NET: "[127.0.0.1, 172.16.0.0/12, 192.168.0.0/16, 10.0.0.0/8]"

Recommended rule-files example:
  rule-files:
    - suricata.rules
    - local.rules
INSTRUCTIONS

echo "[5/5] Testing Suricata configuration..."
sudo suricata -T -c "${SURICATA_CONF}" -v

echo "Configuration test complete."
