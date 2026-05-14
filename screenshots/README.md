# Screenshot Checklist

Use this checklist when collecting evidence for the final report.

- [ ] WSL Ubuntu version
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
