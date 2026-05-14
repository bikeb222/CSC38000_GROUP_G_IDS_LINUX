# Sample suricata.yaml Changes

Edit the Suricata configuration file:

```bash
sudo nano /etc/suricata/suricata.yaml
```

## 1. Set HOME_NET

`HOME_NET` tells Suricata which systems belong to the protected network. In WSL, include localhost and common private network ranges.

```yaml
HOME_NET: "[127.0.0.1, 172.16.0.0/12, 192.168.0.0/16, 10.0.0.0/8]"
```

## 2. Enable EVE JSON Output

EVE JSON must be enabled because EveBox reads Suricata alerts from this file.

```yaml
outputs:
  - eve-log:
      enabled: yes
      filetype: regular
      filename: eve.json
```

Expected output path:

```text
/var/log/suricata/eve.json
```

## 3. Add local.rules to rule-files

The `rule-files` section must include the ET Open rule file and the custom local rule file.

```yaml
rule-files:
  - suricata.rules
  - local.rules
```

## 4. Copy local.rules into Suricata rules directory

This command copies the project rules into Suricata's configuration rule directory.

```bash
sudo cp suricata/local.rules /etc/suricata/rules/local.rules
```

If your `suricata.yaml` uses a different `default-rule-path`, place `local.rules` in that directory or update the rule path in the configuration.

## 5. Test Suricata configuration

This command validates the YAML configuration and rule syntax before running the IDS.

```bash
sudo suricata -T -c /etc/suricata/suricata.yaml -v
```
