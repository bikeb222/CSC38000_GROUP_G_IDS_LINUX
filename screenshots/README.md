# Screenshot Checklist

Use this checklist when collecting evidence for the final report. This directory must contain real screenshots before submission; the checklist alone is not enough evidence.

- [ ] Ubuntu version and environment type, such as WSL/WSL2, VM, or native install
- [ ] Suricata installed successfully
- [ ] `suricata --build-info` output
- [ ] `suricata-update` output
- [ ] `local.rules` file
- [ ] `suricata.yaml` rule-files section
- [ ] Suricata configuration test success
- [ ] Suricata running live
- [ ] Generated test traffic
- [ ] `fast.log` alerts
- [ ] `eve.json` alerts
- [ ] EveBox dashboard open in browser
- [ ] EveBox showing custom alerts
- [ ] EveBox alert details page

Recommended files for alert screenshots:

```text
/tmp/suricata-pcap-verification/suricata-output/fast.log
/tmp/suricata-pcap-verification/suricata-output/eve.json
```

Recommended command for a concise custom alert screenshot:

```bash
sudo grep "LOCAL" /tmp/suricata-pcap-verification/suricata-output/fast.log
```

Before final submission, replace this checklist-only state by adding actual screenshot files to this directory. Use clear filenames such as `01_ubuntu_version.png`, `02_suricata_build_info.png`, and `12_evebox_alert_details.png`.
