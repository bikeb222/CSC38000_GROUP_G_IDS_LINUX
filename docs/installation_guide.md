# Installation Guide

This guide explains how to install the project on Ubuntu Linux. The workflow was tested on WSL/WSL2 and is also suitable for native Ubuntu or an Ubuntu VM.

## Recommended One-Command Deployment

For a teammate deployment, use the automated script from the project root.

```bash
./scripts/00_deploy_all.sh
```

This installs dependencies, installs Suricata, updates ET Open rules, installs EveBox, configures custom local rules, verifies alerts with PCAP/offline mode, and starts EveBox.

The manual steps below are kept for troubleshooting and for explaining the installation process in the final report.

## 1. Enter the Project Directory

This command moves the terminal into the repository that contains the scripts and documentation.

```bash
cd CSC38000_GROUP_G_IDS_LINUX
```

## 2. Install Basic Tools

This script installs utilities needed for package management, network testing, JSON log filtering, and traffic generation.

```bash
./scripts/01_install_dependencies.sh
```

## 3. Install Suricata

This script adds the OISF stable PPA, installs Suricata, and prints Suricata build information.

```bash
./scripts/02_install_suricata.sh
```

## 4. Update ET Open Rules

This command downloads and installs the ET Open community ruleset through `suricata-update`.

```bash
./scripts/04_update_rules.sh
```

## 5. Install Custom Local Rules

This script copies the project rules into Suricata's rule directory, backs up `suricata.yaml` if needed, and runs a configuration test.

```bash
./scripts/03_configure_suricata.sh
```

If the configuration test fails, edit `/etc/suricata/suricata.yaml` and verify `HOME_NET`, `rule-files`, and EVE JSON output.

## 6. Install EveBox

This script checks whether EveBox is already installed. If it is not installed, it adds the official EveBox stable APT repository and installs the current `evebox` package.

```bash
./scripts/05_install_evebox.sh
```

After installing EveBox, confirm that the binary is available.

```bash
evebox --version
```

## 7. Confirm Installation

These commands confirm that Suricata is installed and that the expected log directory exists.

```bash
suricata --build-info
sudo ls -lah /var/log/suricata/
```
