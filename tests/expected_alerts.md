# Expected Alerts

| Test | Command | Expected Signature | SID |
|---|---|---|---|
| ICMP Ping | `ping -c 4 127.0.0.1` | LOCAL ICMP Ping Detected | 1000001 |
| Nmap SYN Scan | `nmap -sS 127.0.0.1` | LOCAL Possible Nmap SYN Scan | 1000002 |
| HTTP Test String | `curl http://127.0.0.1:8080/test-attack` | LOCAL Suspicious HTTP Test String Detected | 1000003 |
| SSH Attempt | `ssh localhost` | LOCAL SSH Connection Attempt | 1000004 |
| Telnet Attempt | `telnet localhost 23` | LOCAL Telnet Traffic Detected | 1000005 |

At least three custom alerts should be demonstrated for the final report. If live capture does not capture one test, document the limitation and use PCAP mode as supporting evidence.

The ICMP and SSH rules are intentionally rate-limited to keep repeated pings and repeated SSH SYN packets from overwhelming the demo logs. The SSH signature still treats any SSH attempt as noteworthy for this class project.
