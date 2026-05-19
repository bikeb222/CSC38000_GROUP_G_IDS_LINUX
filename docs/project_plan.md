# Project Plan

## Objective

Design and implement a signature-based Intrusion Detection System on Ubuntu Linux using Suricata IDS. The system must detect suspicious traffic with ET Open signatures and custom local signatures, write alerts to Suricata logs, and display alerts in the EveBox GUI. The project was tested on WSL/WSL2 but is not limited to WSL.

## Scope

The project focuses on detection and alert visualization. Suricata is responsible for traffic inspection and rule matching. EveBox is responsible for reading Suricata EVE JSON alerts and presenting them in a browser-based dashboard.

## Implementation Phases

1. Prepare the Ubuntu Linux environment with required tools.
2. Install Suricata from the OISF stable PPA.
3. Install and update ET Open rules with `suricata-update`.
4. Add custom local signatures for ICMP, Nmap SYN scan behavior, HTTP test URI strings, SSH attempts, and Telnet traffic.
5. Configure `suricata.yaml` with the correct `HOME_NET`, rule files, and EVE JSON output.
6. Test Suricata configuration with `suricata -T`.
7. Run Suricata in live interface mode.
8. Generate safe local test traffic.
9. Validate alerts in `fast.log` and `eve.json`.
10. Run EveBox and confirm that alerts appear in the GUI.
11. Use offline PCAP mode as a backup validation method if live capture is limited.
12. Collect screenshots and write the final report.

## Success Criteria

- Suricata is installed and can print build information.
- ET Open rules are installed with `suricata-update`.
- Custom `local.rules` contains at least five signature-based detection rules.
- Suricata configuration test passes.
- Suricata writes alerts to `fast.log` and `eve.json`.
- EveBox opens in a browser and displays Suricata alerts.
- At least three custom alerts are triggered by test traffic.
- Documentation explains Linux environment limitations and PCAP-based testing.
