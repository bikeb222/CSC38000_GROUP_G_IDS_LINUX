# Test Commands

## Recommended Automated Test

This command is the easiest way to verify the project across WSL, VM, or native Ubuntu environments. It captures safe local traffic to a PCAP file, runs Suricata in offline mode, and prints the expected custom `LOCAL` alerts.

```bash
./scripts/10_fix_config_and_verify_alerts.sh
```

This command starts EveBox with the verified EVE JSON alert file.

```bash
./scripts/11_start_evebox_demo.sh
```

Open:

```text
http://127.0.0.1:5636
```

## 1. Start Suricata in Live Mode

This command starts Suricata on the default route interface, often `eth0`.

```bash
./scripts/06_run_suricata_live.sh
```

This command starts Suricata on loopback, which is useful for traffic sent to `127.0.0.1`.

```bash
./scripts/06_run_suricata_live.sh lo
```

## 2. Generate Test Traffic

This script runs the ICMP, HTTP, Nmap, SSH, and optional Telnet tests.

```bash
./scripts/08_generate_test_traffic.sh
```

## 3. Run Individual Tests Manually

This command sends ICMP echo requests.

```bash
ping -c 4 127.0.0.1
```

This command starts a simple HTTP server.

```bash
python3 -m http.server 8080 --bind 127.0.0.1
```

This command requests the suspicious test URI.

```bash
curl "http://127.0.0.1:8080/test-attack"
```

This command runs a SYN scan. It may require `sudo`.

```bash
sudo nmap -sS 127.0.0.1
```

This command attempts an SSH connection without requiring a successful login.

```bash
ssh -o ConnectTimeout=3 localhost
```

This command attempts Telnet traffic to port 23.

```bash
telnet localhost 23
```

## 4. Verify Alerts in fast.log

This command follows Suricata's human-readable alert log.

```bash
sudo tail -f /var/log/suricata/fast.log
```

## 5. Verify Alerts in eve.json

This command follows Suricata's structured JSON log and prints only alert events.

```bash
sudo tail -f /var/log/suricata/eve.json | jq 'select(.event_type=="alert")'
```

## 6. Start EveBox

This command starts the GUI using Suricata's EVE JSON alerts.

```bash
./scripts/07_run_evebox.sh
```

Open:

```text
http://127.0.0.1:5636
```

## 7. Run PCAP Mode

This command analyzes a saved packet capture file if live capture is limited.

```bash
./scripts/09_run_suricata_pcap.sh path/to/file.pcap
```
