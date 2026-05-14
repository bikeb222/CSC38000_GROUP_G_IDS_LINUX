# Testing Plan

## Purpose

The testing plan verifies that Suricata detects traffic using signature rules and that EveBox displays alerts from Suricata's EVE JSON log.

## Recommended Verification

Use the automated PCAP verification script for WSL deployments.

```bash
./scripts/10_fix_config_and_verify_alerts.sh
```

This script captures safe local traffic to a PCAP file, runs Suricata against that PCAP, and prints custom `LOCAL` alerts from both `fast.log` and `eve.json`.

Start EveBox with the verified alert file:

```bash
./scripts/11_start_evebox_demo.sh
```

Open:

```text
http://127.0.0.1:5636
```

## Test Modes

Live traffic mode runs Suricata on a WSL network interface. The default interface is usually `eth0`, but localhost tests may require `lo`.

```bash
./scripts/06_run_suricata_live.sh
./scripts/06_run_suricata_live.sh lo
```

PCAP mode runs Suricata against a saved packet capture file. This mode is useful when WSL live capture does not behave as expected.

```bash
./scripts/09_run_suricata_pcap.sh path/to/file.pcap
```

## Test Procedure

1. Start Suricata in live mode.
2. Generate safe test traffic with the traffic script.
3. Check `fast.log` for human-readable alerts.
4. Check `eve.json` for structured JSON alerts.
5. Start EveBox and confirm that the same alerts appear in the web GUI.
6. If live capture fails, repeat validation using PCAP mode.

## Generate Test Traffic

This script sends ICMP traffic, requests an HTTP URI containing `test-attack`, runs an Nmap SYN scan, attempts SSH, and optionally attempts Telnet.

```bash
./scripts/08_generate_test_traffic.sh
```

## Verify Fast Log

This command displays Suricata's simple alert log.

```bash
sudo tail -f /var/log/suricata/fast.log
```

## Verify EVE JSON Alerts

This command filters the structured EVE JSON log to show only alert events.

```bash
sudo tail -f /var/log/suricata/eve.json | jq 'select(.event_type=="alert")'
```

## Verify EveBox

This command starts EveBox in standalone SQLite mode using the Suricata EVE JSON log.

```bash
./scripts/07_run_evebox.sh
```

Open the dashboard:

```text
http://127.0.0.1:5636
```

## Minimum Passing Result

The project should trigger at least three custom alerts. Good candidates are ICMP ping, HTTP test string, and SSH or Nmap connection behavior. If one test does not alert in WSL live mode, document the limitation and validate with PCAP mode.
