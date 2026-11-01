# Ticket 1 - New developer starts Monday, needs a test machine

## 1. What was asked

```
From: Aigerim T. (Office Manager)
Subject: test machine for new dev

Hi, we have someone starting on Monday and he needs a test computer
set up. Nothing special, just so he can try things without breaking
anything. Can you write down how to do it so I can do the next one
myself? Thanks
```

## 2. What was actually needed

### 2.1 What the request left out, and what I assumed instead

I could not ask Aigerim, so I made each of these decisions myself and wrote them down.

| Missing information | What I would have asked | What I assumed |
|---|---|---|
| Operating system | Which OS does the developer work on, Linux, Windows or both? | Both. I built one Linux and one Windows VM so he can test on either. |
| Linux distribution and type | Does he need a desktop or only a command line? | Ubuntu Server (current LTS), because it is light and a test machine needs no graphical interface. If he wants a desktop, Ubuntu Desktop would be the better choice. |
| Windows version and licence | Which Windows version? Do we have a licence? | Windows 11 Enterprise (Evaluation) from Microsoft's evaluation centre, installed without a product key. The evaluation edition stops being usable after its trial period, so it fits a test machine but not long-term use. |
| Resources | How much of the computer can the VMs use? | See 2.3 below. |
| Internet | Does the machine need internet access? | Yes, for updates and downloads. |
| "Without breaking anything" | Does he need a way to go back to a clean state? | Yes. I took a snapshot of each VM right after installation. |
| Hypervisor | Is there a company standard? | VMware Workstation Pro, because it was already installed on my laptop from earlier labs. |
| Where it runs | On whose computer, and will it be used by one person? | On my laptop, as a build to document. The document is written for someone to repeat it on another computer. |

### 2.2 Where the request is wrong or unclear

"A test computer" suggests a physical machine, but a virtual machine does the same job without extra hardware, and it can be reset with a snapshot, which fits "without breaking anything". "Write down how to do it so I can do the next one myself" shows that the real deliverable is a document that a non-expert can follow, not the machine, so BUILD.md is written for a reader who has never opened a hypervisor.

### 2.3 Resources, calculated from my host

| Resource | Host | Ubuntu guest | Windows guest | Left for the host |
|---|---|---|---|---|
| RAM | 16 GB (2 x 8 GB, 3200 MHz) | 4 GB | 4 GB | 8 GB (50%) |
| CPU | i5-13420H, 8 cores / 12 threads | 2 vCPUs | 2 vCPUs | 8 of 12 threads |
| Disk | 476.21 GB total, 355.46 GB free (NVMe) | 25 GB | 64 GB | about 266 GB free even if both disks fill completely |

Why these numbers:

- **RAM:** the two guests together take half of the host's memory. The host needs the other half, because Windows alone uses around 6 GB when idle. 4 GB is the practical minimum for a Windows 11 guest.
- **CPU:** two vCPUs per guest uses 4 of the 12 threads and never more than half of the host's cores.
- **Disk:** 64 GB is the Windows 11 minimum. 25 GB is enough for Ubuntu Server and a developer's tools. Both disks are thin (not preallocated), so they only take real space as they fill.
- **Host check:** UEFI firmware, hardware virtualization enabled.

### 2.4 Settings that differ from the wizard defaults, and why

| Setting | Value I used | Why |
|---|---|---|
| Ubuntu memory | 4096 MB | Host budget above. |
| Ubuntu disk | 25 GB, single file, not preallocated | Enough for the server and tools, and thin so it does not take 25 GB at once. |
| Windows memory | 4096 MB | Minimum for Windows 11. |
| Windows disk | 64 GB, single file, not preallocated | Windows 11 minimum. |
| Processors (both) | 2 cores | Keeps most of the host's threads free. |
| Encryption | "Only the files needed to support a virtual TPM", with a password | The wizard asked for it. Windows 11 requires a virtual TPM, and VMware requires encryption for it. I chose the smaller scope so the disk is not slowed down. |
| Network adapter (both) | NAT | The guests reach the internet through the host and share the same virtual network (VMnet8), so they can reach each other. Bridged would put them on the real network, which may filter an unknown MAC address. |
| OpenSSH server (Ubuntu) | Installed | The server console has no clipboard, so connecting from the host over SSH lets me copy command output. |
| Windows Firewall | Added a rule allowing incoming ping | Without it Ubuntu could not ping Windows (see 2.6). |
| VM names | `ticket1-ubuntu`, `ticket1-windows` | Clear names that match the ticket. |

### 2.5 Evidence that both guests reach the internet and can see each other

`evidence/05-ping-between-guests.txt` contains pings in both directions (Ubuntu to Windows and Windows to Ubuntu). The internet tests (`ping 8.8.8.8` and `ping google.com` on both guests) are described in BUILD.md Step 15.

### 2.6 What went wrong and how I resolved it

1. **Windows Firewall blocked ping.** When I pinged the Windows VM from Ubuntu, the command appeared to freeze and then reported 100% packet loss. Windows Firewall blocks incoming ping by default. I added a rule with `netsh`, but my first attempt failed with "One or more essential parameters were not entered", because the command was split over two lines. I entered it as one line, it answered `Ok.`, and the ping then worked in both directions.
2. **Windows did not start the installer.** The VM showed "Time out." and "EFI Network...". The "Press any key to boot from CD or DVD" prompt had expired before I pressed a key, so the VM tried to boot from the network. I restarted the VM and pressed a key inside the VM window as soon as the prompt appeared.
3. **Ubuntu started in the UEFI Boot Manager.** The virtual disk was empty, so the firmware had nothing to boot. I chose "EFI VMware Virtual SATA CDROM Drive", which started the Ubuntu installer.

## 3. What I did

1. Checked the host's real resources (CPU, RAM, disk, firmware, virtualization). The figures are in 2.3.
2. Chose VMware Workstation Pro because it was already installed and licensed on my laptop. I did not reuse my old lab VMs, because the build document has to describe a build from nothing.
3. Downloaded the Ubuntu Server ISO (current LTS) from ubuntu.com and the Windows 11 Enterprise evaluation ISO from Microsoft's evaluation centre.
4. Created the Ubuntu VM with the New Virtual Machine wizard (Typical): ISO, name `ticket1-ubuntu`, TPM encryption password, 25 GB disk, 4096 MB memory, 2 processors, NAT.
5. Installed Ubuntu Server in the text installer: English, English (US) keyboard, Ubuntu Server (not minimized), automatic network (DHCP), no proxy, default mirror, entire disk, my profile, OpenSSH server, no extra snaps.
6. Recorded the system information:
   ```
   uname -a
   ```
7. Created the Windows VM the same way: `ticket1-windows`, TPM encryption password, 64 GB disk, 4096 MB memory, 2 processors, NAT. Installed Windows 11 Enterprise (Evaluation) with a local account.
8. Found the IP address of each VM:
   ```
   ip addr        # Ubuntu
   ipconfig       # Windows
   ```
9. Tested the internet from both guests:
   ```
   ping -c 4 8.8.8.8
   ping -c 4 google.com
   ```
   On Windows I used `ping 8.8.8.8` and `ping google.com`.
10. Tested Ubuntu to Windows, which failed because of the firewall. In an Administrator Command Prompt on Windows I added a rule (problem 1 in 2.6):
    ```
    netsh advfirewall firewall add rule name="Allow ICMPv4 Echo" protocol=icmpv4:8,any dir=in action=allow
    ```
    Why this and not turning the firewall off: the rule opens only ping and leaves the rest of the firewall working.
11. Ran the ping in both directions and saved the output:
    ```
    ping -c 4 <windows-ip>     # from Ubuntu
    ping <ubuntu-ip>           # from Windows
    ```
12. Took a snapshot named `clean-install` of each VM and screenshotted Snapshot Manager.
13. Wrote BUILD.md while building, step by step, with a screenshot and a reason for each choice.

## 4. Evidence

- `evidence/01-new-vm-wizard.png` - the New Virtual Machine wizard with Typical selected.
- `evidence/02-disk-settings.png` - the Ubuntu disk set to 25 GB, single file, not preallocated.
- `evidence/03-network-adapter.png` - the Ubuntu network adapter set to NAT.
- `evidence/04-guest-uname.txt` - `uname -a` from the Ubuntu guest, proving it is running Linux x86_64.
- `evidence/05-ping-between-guests.txt` - ping replies in both directions, proving the guests see each other.
- `evidence/06-snapshot-list.png` - Snapshot Manager showing `clean-install` for the Ubuntu VM.
- `evidence/06-snapshot-list2.png` - Snapshot Manager showing `clean-install` for the Windows VM.
- `evidence/05-windows-disk-settings.png` - the Windows disk set to 64 GB, single file, not preallocated.
- `evidence/07-windows-wizard.png` - the wizard with the Windows ISO selected.
- `evidence/08-ubuntu-encryption.png` - the encryption page for the Ubuntu VM, with only the TPM files selected.
- `evidence/08-windows-encryption.png` - the same page for the Windows VM.
- `evidence/09-just-opened-vm.png` - the Ubuntu VM right after first power-on.
- `evidence/09-windows-network-adapter.png` - the Windows network adapter set to NAT.
- `evidence/10-windows-setup.png` - the Windows Setup option screen.
- `evidence/10-ip-addresses.png`, `evidence/10-ip-addresses2.png` - the IP addresses of both guests, showing they are on the same virtual network.

## 5. What I would do differently

- I would check which Ubuntu ISO I had (Server or Desktop) before writing the document. A Server ISO has no desktop, no Easy Install and no clipboard sharing, and I had to rewrite parts of BUILD.md after I noticed.
- I would take every screenshot at the moment of the click and name it at once. Several wizard pages disappear after Next, and I had to repeat steps to capture them.
- I would write the exact firewall command into BUILD.md before testing it, with a warning that it must be typed as a single line. I only found that out because my first attempt failed.
- I would ask someone to follow BUILD.md on a clean VM before the peer review, and fix every place where I skipped a step because I already knew the answer.