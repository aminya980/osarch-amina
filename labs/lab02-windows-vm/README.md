Pair: Amina Marlenkyzy   Driver first half: Amina
Machine: Asus Vivobook 16x, Windows 11, guest Ubuntu Server: 26.04, Windows 11 Enterprise eval
Date: 31.10.2026

## What I did
1. Downloaded Windows 11 Enterprise evaluation. Licence: https://go.microsoft.com/fwlink/?LinkId=2382600&clcid=0x409&culture=en-us&country=us
2. Created lab02-windows: 2 vCPU, 4 GB, 64 GB thin, UEFI + Secure Boot, vTPM.
3. Network mode: NAT, both guests. Why: I used NAT Network because both guests must see each other and the internet, and bridged mode is blocked on campus and home Wi-Fi.
4. Ping Ubuntu → Windows timed out because 
- Ping sends an ICMP echo request.
- Windows Defender Firewall blocks incoming echo requests by default.
- Check which profile your network has with Get-NetConnectionProfile. A fresh VM network is usually Public, the strictest profile.. Fixed with: Opened PowerShell as Administrator and ran:
New-NetFirewallRule -DisplayName "Allow ping in (ICMPv4)" -Protocol ICMPv4 -IcmpType 8 -Direction Inbound -Action Allow
5. Overcommitment: set 9.9 GB + 9.9 GB on a 16 GB host.

## Network diagram
```
              Internet
                 |
      Host laptop 192.168.1.12 (Wi-Fi)
                 |
     [VMware NAT · VMnet8 · 192.168.252.0/24]
          /                        \
lab01-ubuntu                  lab02-windows
192.168.252.131                192.168.252.132
```

## Result
| | Before | After |
|---|---|---|
| Host RAM in use | 7,6 Gb | 15 Gb |
| Available | 7,9 Gb | 637 Mb |
| Commited / Swap used | 15,1 / 19,2 GB | 28,3 / 32,4 Gb |
| What I noticed | — | window started freezing and the Ubuntu vm waas lagging a bit when I ran sudo apt update |

## What did not work the first time
At first I just created ip-addr-linux.txt file manually, without using terminal and the 'ssh aminam@192.168.252.131 "ip addr" > labs/lab02-windows-vm/evidence/ip-addr-linux.txt' line, which didn't put information right into it and gave me the same error: "couldn't find this file" or "it already exists" when I tried to find it after.

## Evidence
- [evidence/ipconfig-windows.txt](evidence/ipconfig-windows.txt) — Windows address
- [evidence/ip-addr-linux.txt](evidence/ip-addr-linux.txt) — Ubuntu address
- [evidence/ping-both-ways.txt](evidence/ping-both-ways.txt) — both directions and the internet
- [evidence/host-memory-before.png](evidence/host-memory-before.png) — host memory, guests off
- [evidence/host-memory-after.png](evidence/host-memory-after.png) — host memory, both guests overcommitted