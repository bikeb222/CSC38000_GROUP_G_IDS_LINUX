# WSL Troubleshooting Guide

## Suricata Does Not Detect Traffic

Try running Suricata on `eth0`, which is commonly the default WSL network interface.

```bash
./scripts/06_run_suricata_live.sh eth0
```

Try running Suricata on `lo` if the test traffic targets `127.0.0.1`.

```bash
./scripts/06_run_suricata_live.sh lo
```

Generate traffic from inside WSL so that Suricata has a better chance of seeing it.

```bash
./scripts/08_generate_test_traffic.sh
```

Use offline PCAP mode as a backup validation method.

```bash
./scripts/09_run_suricata_pcap.sh path/to/file.pcap
```

Check whether WSL is using NAT or mirrored networking. WSL networking mode can affect which traffic is visible to Linux packet capture tools.

## EveBox Cannot Read eve.json

Check whether the file exists.

```bash
ls -lah /var/log/suricata/eve.json
```

Check file permissions. If the file is owned by root, run EveBox with `sudo`, as the project script does.

```bash
sudo evebox server --sqlite /var/log/suricata/eve.json
```

Confirm that Suricata has generated alerts. EveBox cannot show alerts that have not been written to `eve.json`.

```bash
sudo tail -f /var/log/suricata/eve.json | jq 'select(.event_type=="alert")'
```

## Browser Cannot Open EveBox

Try opening EveBox through localhost.

```text
http://127.0.0.1:5636
```

If localhost does not work from the Windows browser, find the WSL IP address and try that address with port `5636`.

```bash
hostname -I
```

Check whether EveBox is listening on port `5636`.

```bash
ss -tulpn | grep 5636
```

## suricata.yaml Test Fails

Run the Suricata configuration test.

```bash
sudo suricata -T -c /etc/suricata/suricata.yaml -v
```

Check the custom rule syntax in `local.rules`.

```bash
suricata -T -c /etc/suricata/suricata.yaml -S suricata/local.rules
```

Check that `local.rules` is in the rule directory referenced by `suricata.yaml`.

```bash
sudo ls -lah /etc/suricata/rules/local.rules
```

If your `default-rule-path` points to a different directory, either copy `local.rules` into that directory or adjust the Suricata configuration so it can find the file.
