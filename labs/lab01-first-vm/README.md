# osarch-amina

## Lab 01: My first Virtual Machine

Pair: Amina Marlenkyzy   Driver first half: Amina
Machine: Asus Vivobook 16x, Windows 11, guest Ubuntu Server: 26.04
Date: 24.10.2026

## What I did
1. ⁠Installed VMware Workstation Pro; License: Free for personal use ([https://blogs.vmware.com/cloud-foundation/2024/05/14/vmware-desktop-hypervisor-pro-apps-now-available-for-personal-use/](https://blogs.vmware.com/cloud-foundation/2024/05/14/vmware-desktop-hypervisor-pro-apps-now-available-for-personal-use/))
2. Created VM lab01-ubuntu: 2 vCPU, 4 GB RAM, 25 GB dynamic disk, NAT.
3. Installed Ubuntu Server, took snapshot clean-install.
4. Broke it
ip -br a                                   # before: the card has an IPv4 address
ping -c 3 ubuntu.com                       # before: replies
sudo sed -i 's/dhcp4: true/dhcp4: false/' /etc/netplan/*.yaml
sudo netplan apply
ip -br a                                   # after: no IPv4 address
ping -c 3 ubuntu.com                       # after: fails
5. Rolled back to clean-install: 
ip -br a                   # the IPv4 address is back
ping -c 3 ubuntu.com

## Resource justification
I gave it 4 GB of my 16 GB because Windows already uses about 6 GB when idle, and I need room for a Windows guest in Lab 2. Gave it 25 GB on hard disk because first of all it is dynamically allocated and this is an acceptable, comfortable value for the very first lab. Used 2 out of my 8 cores because it needs never more than half of your host's cores and that's enough as a default value. And NAT for the network adapter so the virtual machine can automatically share my laptop’s internet connection without needing its own separate IP address on the local network.

## Result
The VM boots; the break-and-rollback cycle is shown in the evidence below.

## What did not work the first time
Two times in the terminal I wrote my username instead of writing my login. That created a lot of struggle in line "ssh aminam@192.168.252.131 "lsb_release -a" > labs/lab01-first-vm/evidence/guest-release.txt".

## Evidence
- [evidence/vm-settings.png](evidence/vm-settings.png) — CPU, memory and disk as configured
- [evidence/guest-release.txt](evidence/guest-release.txt) - Ubuntu Server is running in the guest
- [evidence/broken.png](evidence/broken.png) - the guest in its broken state
- [evidence/works-again.png](evidence/works-again.png) - everything works after the rollback
- [evidence/snapshot-list.png](evidence/snapshot-list.png) - the snapshot, after the rollback