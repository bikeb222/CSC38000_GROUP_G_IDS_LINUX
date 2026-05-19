# Suricata Configuration Notes

## Configuration File

The main Suricata configuration file is usually:

```text
/etc/suricata/suricata.yaml
```

Always create a backup before editing this file. The configuration script creates `/etc/suricata/suricata.yaml.bak` if it does not already exist.

The project intentionally does not include a complete replacement `suricata.yaml` because the packaged file can vary by Suricata version. Use the notes below to update the installed file, then run a configuration test.

## HOME_NET

`HOME_NET` defines the protected network. For this project, it should include localhost and common private IP ranges used by WSL, VM, or native Ubuntu test environments.

```yaml
HOME_NET: "[127.0.0.1, 172.16.0.0/12, 192.168.0.0/16, 10.0.0.0/8]"
```

## Rule Files

Suricata must load both ET Open rules and the project custom rules.

```yaml
rule-files:
  - suricata.rules
  - local.rules
```

If Suricata reports that it cannot find `local.rules`, check the value of `default-rule-path` in `suricata.yaml`. The local rule file must be placed in the directory Suricata uses for rule files, or the configuration must reference the correct path.

## EVE JSON

EVE JSON should be enabled because EveBox reads alerts from this structured log.

```yaml
outputs:
  - eve-log:
      enabled: yes
      filetype: regular
      filename: eve.json
```

The expected full path is:

```text
/var/log/suricata/eve.json
```

## Configuration Test

Run this command after changing Suricata configuration or rules.

```bash
sudo suricata -T -c /etc/suricata/suricata.yaml -v
```
