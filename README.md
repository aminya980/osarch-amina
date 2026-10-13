# osarch-amina

## Lab 00: Inventory

| What | Value | Where I got it |
| --- | --- | --- |
| CPU Model, Cores, Threads | 13th Gen Intel(R) Core(TM) i5-13420H | `Get-CimInstance -ClassName Win32_Processor` |
| Total RAM, Modules & Speed | 16 GB (2 modules x 8 GB @ 3200 MHz) | `Get-CimInstance -ClassName Win32_PhysicalMemory` |
| Disk Model & Type | WD PC SN5000S 512GB (Fixed hard disk media SCSI) | `Get-CimInstance -ClassName Win32_DiskDrive` |
| Free Volume Space | Смотрите в evidence/disk.txt | `Get-Volume` |
| Firmware Type, Version & Date | BIOS, K3605VC.315 (American Megatrends International, LLC, 24.04.2025) | `Get-CimInstance -ClassName Win32_BIOS` |
| Hardware Virtualization | True (Enabled) | `(Get-CimInstance -ClassName Win32_Processor).VirtualizationFirmwareEnabled` |

## Virtualization Status
Hardware virtualization is present and enabled.

## What did not work
Everything worked as expected using PowerShell commands.