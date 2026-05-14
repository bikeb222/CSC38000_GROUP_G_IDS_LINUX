#!/usr/bin/env bash
set -euo pipefail

SURICATA_CONF="/etc/suricata/suricata.yaml"

if [[ "$#" -ne 1 ]]; then
  echo "Usage: $0 path/to/file.pcap" >&2
  exit 1
fi

PCAP_FILE="$1"

if [[ ! -r "${PCAP_FILE}" ]]; then
  echo "ERROR: PCAP file is not readable: ${PCAP_FILE}" >&2
  exit 1
fi

if ! sudo test -f "${SURICATA_CONF}"; then
  echo "ERROR: ${SURICATA_CONF} does not exist. Install and configure Suricata first." >&2
  exit 1
fi

echo "Running Suricata in offline PCAP mode against: ${PCAP_FILE}"
sudo suricata -c "${SURICATA_CONF}" -r "${PCAP_FILE}"

echo "PCAP analysis complete. Check /var/log/suricata/fast.log and /var/log/suricata/eve.json."
