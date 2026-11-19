**Task 1**

1: Yes it could run two machines at the same time, having 16 GB on the host allows it, then giving VMs only 2-4 GB is enough because Windows already uses about 6 GB when idle.

| What | Memory |
|---|---|
| Host OS idle (I measured maybe around 7,6 GB in use on my Windows 11 laptop in Lab 2 with guests off; scale down for a lighter OS, e.g. Linux host ~2 GB) | ~7.6 GB |
| Ubuntu guest | 2 GB |
| Windows 11 guest | 4 GB (Windows 11 minimum) |
| Hypervisor (VMware) itself | ~0.5 GB |

- **CPU:** host has 8 cores / 16 threads; guests 2 + 2 = 4 vCPU; ≤ half the host cores per VM. Virtualization (VT-x / AMD-V) in firmware?
- **Disk:** thin max 25 + 64 = **89 GB** vs free space, SSD 
- **Windows 11 guest needs:** 2 vCPU, 4 GB RAM, 64 GB disk, UEFI + Secure Boot, TPM 2.0 (hypervisor can give a vTPM).
- Verdict: **Yes it could run them both**

2: Decision order:
1. **RAM** is almost always first for VMs (smallest margin → host pages). Check: **slots free? both full? soldered (laptop LPDDR)? max capacity? DDR generation?**
   - Both slots full → *replace* 2 × 8 with 2 × 16, don't add.
   - Free slots on AM5 → 2 sticks run faster than 4 (Ryzen 7600: DDR5-5200 with 2 modules, **DDR5-3600 with 4**).
   - Soldered → **cannot** be upgraded beacuse it is alright and already built in.
2. **Disk** next: HDD → NVMe/SATA SSD for the VM folder; free M.2 slot?
3. CPU last (needs same socket, maybe BIOS update).

3:
|  | The card machine | My laptop (Lab 0) | Better |
|---|---|---|---|
| CPU | AMD Ryzen 7 7735HS, 8 cores, 16 threads | i5-13420H, 8 cores / 12 threads | |
| Memory | 16 GB DDR-4800, soldered to the board | 16 GB DDR4-3200, 2 × 8 GB SO-DIMM (one likely soldered — check) | |
| Disk | 512 GB NVMe SSD | 512 GB NVMe SSD (WD SN5000S), 280.69 GB free on 08.11 | |

**Task 2**

1. I took a snapshot before-ckpt1 (VM → Snapshot → Take Snapshot) so I can roll back if the guest breaks.
   Result: it shows in Snapshot Manager.
2. I added a 1 GB disk (VM Settings → Add → Hard Disk).
   Result: it appears in the VM’s device list.
3. lsblk: I expected a new 1G disk sdb with no partitions (`sda` is the system disk). This confirms the device name before I write to it.
   Result: [paste output]
4. sudo parted /dev/sdb —script mklabel gpt mkpart data ext4 1MiB 100%: creates a GPT table and one partition. It prints nothing on success; lsblk should then show sdb1 of about 1G.
   Result: [FAILED: “sudo: Authentication failed”. I retried with the correct password / the problem was ___.]
5. sudo mkfs.ext4 /dev/sdb1: expected “Writing superblocks and filesystem accounting information: done”.
6. sudo mkdir /data && sudo mount /dev/sdb1 /data: no output; df -h /data shows /dev/sdb1 mounted on /data.
7. sudo blkid /dev/sdb1: gives UUID=“...” TYPE=“ext4”. I copied the UUID.
8. echo ‘UUID=<real-uuid> /data ext4 defaults,nofail 0 2’ | sudo tee -a /etc/fstab: it prints the line back. I checked with tail -n 2 /etc/fstab.
9. sudo umount /data && sudo mount -a: no output means no error in fstab. findmnt /data; df -h /data show it mounted.
10. sudo reboot, then findmnt /data: still mounted, which proves it survives a reboot. [Optional: ls /data shows lost+found.]

**Justification**:
- GPT: supports disks over 2 TB and 128 partitions, and keeps a backup header. MBR is limited to 2 TB and 4 primary partitions.
- UUID in fstab: /dev/sdX names can change when disks are added or reordered; the UUID stays with the filesystem.
- Alternatives: LVM is flexible but more complex. A label or a systemd mount unit also works.
- nofail: a mount error won’t stop the boot.
-----
- Why GPT: it handles disks over 2 TB, allows 128 partitions, keeps a backup header, and is the UEFI standard. MBR is limited to 2 TB and 4 primary partitions.
- Why UUID: /dev/sdX names can change when disks are added or reordered. The UUID belongs to the filesystem.
- Alternatives and trade-offs: LVM is flexible but adds complexity. A label or a systemd mount unit also works.
- Verification: mount -a succeeds before the reboot, and findmnt shows /data after it.

**Task 3**

**E1**: Symptom: Ubuntu --> Windows ping gets 100% loss
**E2**: Diagnosis path:
E Shows Conclusion E4 Windows → Ubuntu ping works (TTL 64) Windows is up, and the network and NAT work E2, E3, E5 Same subnet 10.0.2.0/24, same NatNetwork, different IPs Not a network or VM-settings problem E7 The “Allow ping in (ICMPv4)” rule doesn’t exist Windows is dropping inbound ICMP E8 Restored from a snapshot dated 20.10, after which the rule was added Explains why the rule vanished
**E3**: Ignored evidence: E6 (all firewall profiles on is normal) and the IPv6 address in E3.
**E4**: Missing evidence: on Windows, run Get-NetFirewallRule -DisplayName “*ICMP*” | Select DisplayName,Enabled. Expect no custom rule, with the built-in Echo Request rule disabled.
**E5**: Root cause: the Lab 2 firewall rule was lost when the snapshot was restored. Windows now blocks inbound ping, and monitoring reports “down” even though the machine is fine.
**E6**: Fix (admin PowerShell): New-NetFirewallRule -DisplayName “Allow ping in (ICMPv4)” -Protocol ICMPv4 -IcmpType 8 -Direction Inbound -Action Allow
**E7**: Verification: ping -c 3 10.0.2.4 from Ubuntu shows 0% loss, and the rule persists after a reboot. To prevent a repeat: take a new snapshot after configuring, and record the rule in the build doc.
