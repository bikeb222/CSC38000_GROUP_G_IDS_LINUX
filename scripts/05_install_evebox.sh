#!/usr/bin/env bash
set -euo pipefail

EVEBOX_VERSION="${EVEBOX_VERSION:-0.24.0}"
EVEBOX_DEB_URL="${EVEBOX_DEB_URL:-https://evebox.org/files/release/latest/evebox-${EVEBOX_VERSION}-amd64.deb}"
DOWNLOAD_DIR="${DOWNLOAD_DIR:-/tmp/evebox-install}"
DEB_FILE="${DOWNLOAD_DIR}/evebox-${EVEBOX_VERSION}-amd64.deb"

echo "[1/4] Checking whether the evebox command is already installed..."
if command -v evebox >/dev/null 2>&1; then
  echo "EveBox is already available:"
  evebox --version || true
  exit 0
fi

echo "[2/4] Preparing download directory..."
mkdir -p "${DOWNLOAD_DIR}"

echo "[3/4] Downloading EveBox ${EVEBOX_VERSION} from the official EveBox release URL..."
if ! curl -fL -o "${DEB_FILE}" "${EVEBOX_DEB_URL}"; then
  cat <<EOF >&2
ERROR: Failed to download EveBox from:
  ${EVEBOX_DEB_URL}

Manual fallback:
  1. Open https://evebox.org/docs/install/
  2. Download the Linux amd64 .deb package.
  3. Install it with:
     sudo apt install ./evebox-<version>-amd64.deb
EOF
  exit 1
fi

echo "[4/4] Installing EveBox package..."
sudo apt install -y "${DEB_FILE}"

echo "EveBox installation result:"
evebox --version
