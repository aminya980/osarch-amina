# Building a Linux and a Windows test machine in VMware Workstation Pro

This document explains how to build two virtual machines (VMs) from nothing: an Ubuntu Linux VM and a Windows VM. Both can reach the internet and can ping each other. Follow the steps in order. After each step there is a **Check** so you know it worked before you continue.

## Before you start

**You need:**
- A computer with hardware virtualization enabled in the BIOS/UEFI (Intel VT-x or AMD-V). To check on Windows: Task Manager > Performance > CPU > "Virtualization: Enabled".
- At least 16 GB RAM and 100 GB free disk. (This build uses 8 GB RAM and up to about 94 GB disk.)
- VMware Workstation Pro, Go to https://support.broadcom.com/#, register or log in, then open My Downloads and search for VMware Workstation Pro (or VMware Fusion). Choose the newest release for your system and download it.
- An Ubuntu ISO: [ubuntu.com/download/serverLinks ](https://ubuntu.com/download/server) for amd64, or [ubuntu.com/download/server/armLinks](https://ubuntu.com/download/server/arm) for ARM64. Take the current LTS release.
- A Windows ISO: Windows ISO Enterprise 64-bit edition, downloaded from [<official URL>.](https://www.microsoft.com/en-us/evalcenter/download-windows-11-enterprise).
- Save both ISOs in downloads!

**Names used in this document:** the VMs are called `ticket1-ubuntu` and `ticket1-windows`.

---

## Part A. The Ubuntu (Linux) VM

### Step 1. Start the New Virtual Machine wizard

Open VMware Workstation. Click **File > New Virtual Machine**. Choose **Typical (recommended)** and click **Next**.

the screenshot [](evidence/01-new-vm-wizard.png)

Why Typical and not Custom: Typical picks safe defaults for hardware compatibility and controller types, and we change only the settings that matter (memory, disk, CPUs) in later steps.

### Step 2. Point the wizard at the Ubuntu ISO

Select **Installer disc image file (iso)**, click **Browse**, choose the Ubuntu ISO and click **Next**.

Why an ISO and not "install later": with an ISO selected, VMware recognises Ubuntu and offers Easy Install, which fills in the user account and installs unattended.

### Step 3. Name the VM and choose where it is stored

Name: `ticket1-ubuntu`. Location: default folder. Click **Next**.

### Step 4. Encrypt the virtual TPM

When the **How would you like to encrypt this virtual machine** is asked,
Choose **Only the files needed to support a virtual TPM** selected, 
Write the password and don't forget it, then click **Next**.

the screenshot [](evidence/08-encryption.png)

Why this option and not "All the files": it satisfies the TPM requirement, and encrypting the whole disk would only make the VM slower for no benefit on a test machine.

### Step 5. Set the disk size

Disk size: 25 GB, dynamically allocated (grows as needed), Store virtual disk as a single file. Do not tick Allocate all disk space now. Click **Next**.

the screenshot [](evidence/02-disk-settings.png)

Why 25 GB: Ubuntu needs about 15 GB for the system, and 10 GB is spare for the developer's tools. The disk is thin (it only uses real space as it fills), so this does not take 25 GB from the host immediately.

### Step 6. Set memory and processors

On the last page click **Customize Hardware**.

**Memory:** 4096 MB (4 GB).
**Processors:** 2 - never more than half of your host's cores.

Why: the host has 16 GB RAM. Two guests at 4 GB each leave 8 GB (50%) for the host, and the Windows already uses about 6 GB when idle. Two cores leave 8 of the host's 12 threads free.

### Step 7. Check the network adapter

Still in Customize Hardware, click **Network Adapter**. Make sure **NAT** is selected. Click **Close**, then **Finish**.

the screenshot [](evidence/03-network-adapter.png)

Why NAT and not Bridged: NAT gives the guest internet access through the host's connection without needing its own address on the physical network, and every NAT guest on the same VMware network (VMnet8) can reach the others.

### Step 8. Install Ubuntu

Start the VM. It may take a few minutes to start.
(To get the mouse back out: Ctrl+Alt.)

the screenshot [](evidence/09-just-opened-vm.png)

Boot menu: choose Try or Install Ubuntu Server.
Language: **English**. If offered an installer update, you can skip it.
Keyboard: **English (US)**.
Type of install: **Ubuntu Server (not minimized)**.
Network: the network card should get an address automatically (DHCP), something like 192.168.x.x or 10.0.2.15. **Continue**.
Proxy: leave empty. Mirror: accept the default and wait for the test to pass.
Storage: Use an entire disk. This is the 25 GB virtual disk — your laptop's real disk is safe. Accept the summary and confirm **Continue**.
**Profile:**
Your name: your name.
Server name: server name.
Username: short, lowercase, for example aigerim.
Password: one you will remember. Write it down on paper — never in your repository.
Ubuntu Pro: **Skip for now**.
SSH: tick **Install OpenSSH server**, then **Done**
Featured server snaps: select nothing. **Continue**
**Wait for Installation complete!**, then choose Reboot Now. If you see "Please remove the installation medium, then press ENTER", just press **Enter**.
Log in with your username and password. Nothing or the "*" will appear while you type the password - that is normal.

### Step 9. Record the system information

Log in at the console with the username and password you created. You are now at a command prompt (there is no desktop on Ubuntu Server). Run:
```
uname -a
```
Copy the output into a text file called `04-guest-uname.txt` (see "Getting files out of the VM" at the end).
Check: the output starts with `Linux ticket1-ubuntu` and shows `x86_64`.

the screenshot [](evidence/04-guest-uname.txt)

---

## Part B. The Windows VM

### Step 10. Start the wizard again

**File > New Virtual Machine > Typical**, select the Windows ISO, click **Next**.

the screenshot [](evidence/07-windows-wizard.png)

### Step 11. Windows encryption

When the **How would you like to encrypt this virtual machine** is asked,
Choose **Only the files needed to support a virtual TPM** selected, 
Write the password and don't forget it, then click **Next**.

the screenshot [](evidence/08-encryption.png)

### Step 12. Name, disk, hardware

- Name: `ticket1-windows`.
- Disk: **64**, single file, thin (do not tick "Allocate all disk space now").
- Customize Hardware: **Memory 4096 MB**, **Processors: 2 cores**, **Network Adapter: NAT**.

![](evidence/05-windows-disk-settings.png)
![](evidence/09-windows-network-adapter.png)

Why?: 64 GB is the Windows 11 minimum disk requirement; 4 GB is the minimum RAM; NAT puts it on the same virtual network as the Ubuntu VM so they can reach each other.

### Step 13. Install Windows

Click **Finish**. Windows installs unattended, restarts a few times and reaches the desktop. This takes a few minutes.

**Start the VM**. When you see "Press any key to boot from CD or DVD…", click inside the window and *press a key quickly*. Missed it? Restart the VM and try again.
When you see the "Select setup option" tou tick all from the screenshot [](evidence/10-windows-setup.png) and **Continue**

Language, time format, keyboard: your choice → **Next** → **Install now**.
If asked for a product key: I don't have a product key. Edition: Windows 11 Enterprise (Evaluation).
Accept the licence terms → Custom: Install Windows only → select Drive 0 Unallocated Space → **Next**. Windows copies files and restarts several times. Do not press a key at the "boot from CD" prompt again.
Setup screens: country, keyboard, skip the second keyboard.
Account: on the sign-in screen choose Sign-in options → Domain join instead, then create a local account (name, password, three security questions).
Privacy settings: after choosing options --> **Accept**.

---

## Part C. Making the two VMs reach the internet and each other

### Step 14. Find each VM's IP address

On Ubuntu, in a terminal:

```
ip addr
```

Look for the line starting `inet` under the adapter named `<ens33>`. Example: `192.168.x.x`.

On Windows, open **Command Prompt** and run:

```
ipconfig
```

Look for **IPv4 Address**.

[](evidence/10-ip-addresses.png)
[](evidence/10-ip-addresses2.png)

### Step 15. Test the internet

On Ubuntu:

```
ping -c 4 8.8.8.8
ping -c 4 google.com
```

On Windows:

```
ping 8.8.8.8
ping google.com
```

Why two tests: the first proves the connection works; the second proves name lookup (DNS) works.
Check: you see replies, and "0% packet loss".

### Step 16. Test Ubuntu to Windows

On Ubuntu, using the Windows IP from Step 14:

```
ping -c 4 <windows-ip>
```

This will probably **fail** (timeouts). Windows Firewall blocks incoming ping by default. (It froze when the PING started and then there was 100% package loss)

To allow it, on Windows open **Command Prompt as Administrator** (right-click > Run as administrator) and run:

```
netsh advfirewall firewall add rule name="Allow ICMPv4 Echo" protocol=icmpv4:8,any dir=in action=allow
```

Why this and not turning the firewall off: it opens only ping, and leaves the rest of the firewall working.

Run the Ubuntu ping again, then test the other direction from Windows:

```
ping <ubuntu-ip>
```

Save the output of both directions in `05-ping-between-guests.txt`.
the screenshot [](evidence/05-ping-between-guests.txt)

Check: both pings show replies with 0% loss.

---

## Part D. Snapshots

### Step 17. Take a snapshot of each VM

For each VM, with it running or shut down: **VM > Snapshot > Take Snapshot**. Name it `clean-install` and add a description such as "Fresh OS, network working". Then open **VM > Snapshot > Snapshot Manager** (Ctrl+M) and take a screenshot.

the screenshot [](evidence/06-snapshot-list.png)
the screenshot 2 [](evidence/06-snapshot-list2.png)

Why: if something is broken later, the developer can return to this working state in a minute.
Snapshot Manager lists `clean-install` exists for both VMs.

---

## Getting files out of the VM

To move `04-guest-uname.txt` or the ping outputs from a VM to the host: [VERIFY: describe what worked for you, e.g. drag and drop (needs VMware Tools / open-vm-tools), copy/paste of the text into a Notepad file on the host, or a shared folder].

## If something goes wrong

- The VM will not start and says virtualization is unavailable: enable VT-x/AMD-V in the BIOS/UEFI.
- No internet in the guest: check that the adapter is **NAT** and shows "connected" at the bottom of the VM window.
- Ping to Windows times out: see Step 16.