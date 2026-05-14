# Design and Implementation of a Signature-Based IDS with Suricata and EveBox on WSL

This project implements a signature-based Intrusion Detection System using Suricata IDS on Ubuntu WSL. Suricata detects suspicious traffic using ET Open rules and custom local rules. Alerts are written to EVE JSON format and displayed through the EveBox web GUI.

## Fast Deployment

For teammates who only need to deploy and verify the project, use the quickstart path:

```bash
cd suricata-evebox-wsl-ids
./scripts/00_deploy_all.sh
```

Then open EveBox:

```text
http://127.0.0.1:5636
```

See `QUICKSTART.md` for the simplified workflow. The rest of this README explains the project design and the manual step-by-step process.

## Project Purpose

The purpose of this project is to design, install, configure, and test a Linux-based Intrusion Detection System. The IDS monitors network traffic, compares packets and flows against known attack signatures, and records alerts when traffic matches a rule. The project uses Ubuntu on WSL as the Linux environment, Suricata as the IDS engine, and EveBox as the graphical interface for reviewing alerts.

## Why This Is Signature-Based

A signature-based IDS detects activity by matching traffic against predefined rules. In this project, Suricata uses two signature sources:

- ET Open rules installed with `suricata-update`.
- Custom rules in `suricata/local.rules`.

Each rule describes a pattern such as an ICMP ping, a TCP SYN scan, an HTTP URI string, or a connection attempt to a sensitive service. Suricata performs the detection. EveBox is used only for GUI alert visualization.

## Why Suricata

Suricata is a widely used open-source IDS, IPS, and network security monitoring engine. It supports signature rules, protocol inspection, offline PCAP analysis, and structured JSON logging through `eve.json`. These features make it a good fit for a reproducible academic IDS project.

## Why EveBox

Suricata writes alerts to log files such as `fast.log` and `eve.json`. EveBox provides a web GUI that reads Suricata EVE JSON alerts and presents them in a dashboard. This makes it easier to inspect alert timestamps, source and destination addresses, protocols, signatures, signature IDs, and severity values.

## Why WSL

Ubuntu on WSL provides a Linux environment on a Windows host without requiring a full virtual machine. This is useful for installation, rule management, scripting, and log analysis. However, WSL packet capture can behave differently from a full Linux VM, so this project supports both live traffic mode and offline PCAP mode.

## Repository Layout

```text
suricata-evebox-wsl-ids/
├── README.md
├── docs/
├── scripts/
├── suricata/
├── tests/
└── screenshots/
```

## Installation

Start from the project directory:

```bash
cd suricata-evebox-wsl-ids
```

Install basic Linux tools used by the project. This includes tools for package setup, network testing, JSON filtering, and simple traffic generation.

```bash
./scripts/01_install_dependencies.sh
```

Install Suricata from the OISF stable PPA. The script also prints Suricata build information, which should be saved as evidence for the final report.

```bash
./scripts/02_install_suricata.sh
```

Update ET Open rules using `suricata-update`.

```bash
./scripts/04_update_rules.sh
```

## Configuration

Copy the custom local rules into the Suricata rules directory and create a backup of the main Suricata configuration file if one does not already exist.

```bash
./scripts/03_configure_suricata.sh
```

Then edit Suricata's configuration file:

```bash
sudo nano /etc/suricata/suricata.yaml
```

Verify these settings:

- `HOME_NET` includes localhost and WSL private network ranges.
- `rule-files` includes both `suricata.rules` and `local.rules`.
- EVE JSON output is enabled and writes to `/var/log/suricata/eve.json`.

Example `HOME_NET` value:

```yaml
HOME_NET: "[127.0.0.1, 172.16.0.0/12, 192.168.0.0/16, 10.0.0.0/8]"
```

Example rule file section:

```yaml
rule-files:
  - suricata.rules
  - local.rules
```

Test the configuration before running the IDS.

```bash
sudo suricata -T -c /etc/suricata/suricata.yaml -v
```

## Run Suricata

Live mode monitors a network interface. The script tries to detect the default WSL interface, usually `eth0`.

```bash
./scripts/06_run_suricata_live.sh
```

For localhost-only tests, you may need to monitor the loopback interface instead:

```bash
./scripts/06_run_suricata_live.sh lo
```

Offline PCAP mode analyzes a packet capture file. This is the backup validation method when WSL live capture is limited.

```bash
./scripts/09_run_suricata_pcap.sh path/to/file.pcap
```

## Run EveBox

Install EveBox or follow the manual installation guidance printed by the script.

```bash
./scripts/05_install_evebox.sh
```

Run EveBox in standalone SQLite mode against Suricata's EVE JSON log.

```bash
./scripts/07_run_evebox.sh
```

Open the GUI in a browser:

```text
http://127.0.0.1:5636
```

## Test Alerts

Generate safe local traffic for the custom signatures.

```bash
./scripts/08_generate_test_traffic.sh
```

Check fast alerts:

```bash
sudo tail -f /var/log/suricata/fast.log
```

Check EVE JSON alerts:

```bash
sudo tail -f /var/log/suricata/eve.json | jq 'select(.event_type=="alert")'
```

Expected custom alerts include ICMP ping detection, possible Nmap SYN scan detection, suspicious HTTP URI detection, SSH connection attempt detection, and Telnet traffic detection.

## Screenshots for Final Report

Collect screenshots of the Ubuntu version, Suricata installation output, `suricata --build-info`, `suricata-update`, `local.rules`, the `suricata.yaml` rule configuration, configuration test success, live Suricata execution, generated test traffic, `fast.log` alerts, `eve.json` alerts, the EveBox dashboard, and EveBox alert details.

See `screenshots/README.md` for the full checklist.

## WSL Limitation Notice

WSL is a valid Linux environment for this project, but it should not be described as identical to a full Linux VM for packet capture. If live interface monitoring does not detect traffic, test traffic generated inside WSL, try a different interface such as `lo` or `eth0`, and use PCAP/offline mode as backup evidence.
