#!/usr/bin/env bash
set -euo pipefail

if [[ -r /etc/os-release ]]; then
  # Load distro metadata so we can choose the right repository flow.
  # shellcheck disable=SC1091
  . /etc/os-release
else
  echo "ERROR: Unable to detect the Linux distribution from /etc/os-release." >&2
  exit 1
fi

install_from_ubuntu_ppa() {
  echo "[1/4] Ensuring add-apt-repository is available..."
  if ! command -v add-apt-repository >/dev/null 2>&1; then
    sudo apt update
    sudo apt install -y software-properties-common
  fi

  echo "[2/4] Adding the official OISF Suricata stable PPA..."
  sudo add-apt-repository -y ppa:oisf/suricata-stable

  echo "[3/4] Installing Suricata..."
  sudo apt update
  sudo apt install -y suricata
}

install_from_debian_repos() {
  local backports_list="/etc/apt/sources.list.d/${VERSION_CODENAME}-backports.list"
  local candidate=""

  has_installable_suricata() {
    candidate="$(apt-cache policy suricata | awk '/Candidate:/ { print $2 }')"
    [[ -n "${candidate}" && "${candidate}" != "(none)" ]]
  }

  echo "[1/4] Refreshing Debian package indexes..."
  sudo apt update

  if has_installable_suricata; then
    echo "[2/4] Installing Suricata from the current Debian repositories..."
    sudo apt install -y suricata
    return
  fi

  echo "[2/4] Suricata is not available in the current Debian repositories."
  echo "      Enabling ${VERSION_CODENAME}-backports and trying again..."
  if [[ ! -f "${backports_list}" ]]; then
    echo "deb http://deb.debian.org/debian ${VERSION_CODENAME}-backports main" \
      | sudo tee "${backports_list}" >/dev/null
  fi

  echo "[3/4] Refreshing package indexes with backports enabled..."
  sudo apt update

  if ! has_installable_suricata; then
    cat <<EOF >&2
ERROR: Suricata is still unavailable for this Debian environment after enabling backports.

Detected distribution:
  ID=${ID}
  VERSION_CODENAME=${VERSION_CODENAME:-unknown}
  VERSION_ID=${VERSION_ID:-unknown}
  Candidate=${candidate:-unknown}

Please inspect:
  apt-cache policy suricata
  /etc/apt/sources.list
  ${backports_list}
EOF
    exit 1
  fi

  echo "[4/4] Installing Suricata from Debian backports..."
  sudo apt install -y -t "${VERSION_CODENAME}-backports" suricata
}

case "${ID:-}" in
  ubuntu)
    install_from_ubuntu_ppa
    ;;
  debian)
    install_from_debian_repos
    ;;
  *)
    cat <<EOF >&2
ERROR: Unsupported distribution: ${ID:-unknown}

This script currently supports:
  - Ubuntu via the OISF PPA
  - Debian via the official repositories or backports
EOF
    exit 1
    ;;
esac

echo "[4/4] Displaying Suricata build information..."
suricata --build-info

echo "Suricata installation complete."
echo "Next step: run ./scripts/03_configure_suricata.sh"
