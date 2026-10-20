# osarch-amina

## Lab 00: Inventory

| What | Value | Where I got it |
| --- | --- | --- |
| CPU Model, Cores, Threads | 13th Gen Intel(R) Core(TM) i5-13420H 8 cores 12 threads | `Get-CimInstance -ClassName Win32_Processor` |
| Total RAM, Modules & Speed | 16 GB (2 modules x 8 GB @ 3200 MHz) | `Get-CimInstance -ClassName Win32_PhysicalMemory` |
| Disk Model & Type | WD PC SN5000S SDEQNSJ-512G-1002 NVMe | `Get-PhysicalDisk \| Select-Object FriendlyName, BusType` |
| Free Volume Space |  free volume: 355.46 GB size: 476.21 GB | `Get-Volume C` |
| Firmware Type, Version & Date | UEFI, American Megatrends K3605VC.315, 24.04.2025 | `Confirm-SecureBootUEFI` |
| Hardware Virtualization | True (Enabled) | `(Get-CimInstance -ClassName Win32_Processor).VirtualizationFirmwareEnabled` |

## What did not work
When trying to find the firmware type using Confirm-SecureBootUEFI, the command returned a "PermissionDenied / UnauthorizedAccessException" error. I realized that this command requires PowerShell to be run as an Administrator, but the integrated VS Code terminal runs as a standard user. Also, initially, I didn't know how to find the specific bus type for the disk or the exact free space on the C drive, but using Get-PhysicalDisk and Get-Volume C solved it.