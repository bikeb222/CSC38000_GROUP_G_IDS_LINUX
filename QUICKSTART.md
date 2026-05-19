# Quickstart for Teammates

This is the shortest deployment path for Ubuntu Linux. It was tested on WSL/WSL2 and can also be used on native Ubuntu or an Ubuntu VM.

## 1. Enter the Project Directory

```bash
cd CSC38000_GROUP_G_IDS_LINUX
```

## 2. Run One Command

This command installs dependencies, installs Suricata, updates ET Open rules, installs EveBox, configures local Suricata rules, verifies custom alerts with PCAP mode, and starts EveBox.

```bash
./scripts/00_deploy_all.sh
```

Enter your Ubuntu `sudo` password when prompted.

## 3. Open EveBox

Open this URL in a browser:

```text
http://127.0.0.1:5636
```

The demo EveBox server is bound to localhost and runs without authentication or TLS. Use it only for a local class demo; do not expose port `5636` to a network.

The GUI should show Suricata alerts imported from:

```text
/tmp/suricata-pcap-verification/suricata-output/eve.json
```

## 4. Expected Successful Output

The verification step should print custom alerts like these:

```text
LOCAL ICMP Ping Detected
LOCAL Possible Nmap SYN Scan
LOCAL Suspicious HTTP Test String Detected
LOCAL SSH Connection Attempt
LOCAL Telnet Traffic Detected
```

## 5. Rerun Only the Demo

Use this command to regenerate the test PCAP and Suricata alerts.

```bash
./scripts/10_fix_config_and_verify_alerts.sh
```

Use this command to restart EveBox with the generated alert file.

```bash
./scripts/11_start_evebox_demo.sh
```

## 6. Evidence Files

Use these files for screenshots and final report evidence.

```text
/tmp/suricata-pcap-verification/local-signature-test.pcap
/tmp/suricata-pcap-verification/suricata-output/fast.log
/tmp/suricata-pcap-verification/suricata-output/eve.json
```

## 7. Important Capture Note

Live packet capture can be inconsistent on some WSL, VM, or host interface setups, especially for localhost traffic. This project uses PCAP/offline mode for reliable reproduction. Suricata still performs the detection, and EveBox still displays Suricata EVE JSON alerts.
