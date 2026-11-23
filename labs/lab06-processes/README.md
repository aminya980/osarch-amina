# Lab 6 — Live processes and memory pressure

Pair: Amina Marlenkyzy · Date: 22–23.11.2026 · Guests: Ubuntu Server 26.04 (3.3 GiB RAM, 2 GiB swap) / Windows 11 Enterprise eval (4 GB RAM) · Hypervisor: VMware Workstation

## Part 1 — One process, three tools
Process chosen: **vmtoolsd** (VMware Tools service) — why: we use VMware, not VirtualBox, so vmtoolsd is the equivalent of the recommended VBoxService and runs as a system service on both guests.

| | Task Manager | Process Explorer | htop / ps |
|---|---|---|---|
| PID | 3396 | 3396 | 1237 |
| Parent (name and PID) | — (not shown) | services.exe (848) | systemd (1) |
| "Memory" as shown by default | 3,024 K (Memory (private working set)) | — (no single "memory" column) | RES 10,976 K / MEM% 0.3 |
| Private memory | Commit size 10,668 K | Private Bytes 10,628 K | — (no column) |
| Working set / RES | 13,356 K | 13,316 K (of it WS Private 2,956 K) | RES 10,976 K (of it SHR 9,332 K) |
| Virtual size | — (not shown) | — (not added) | VSZ 114,040 K (VIRT 111M) |
| Handles / file descriptors | 402 | 400 | 9 |
| Threads | 14 | 13 | 4 (NLWP) |

Evidence: [task-manager.png](evidence/task-manager.png), [process-explorer.png](evidence/process-explorer.png), [htop.png](evidence/htop.png).
Linux numbers from `ps -o pid,ppid,user,rss,vsz,nlwp,cmd -p 1237` → `1237 1 root 10976 114040 4 /usr/bin/vmtoolsd`, `sudo ls /proc/1237/fd | wc -l` → `9`, and `ps -p 1 -o pid,comm` → `1 systemd`.

Note: Windows has a second vmtoolsd.exe (PID 9284, user amina) — the per-user part of VMware Tools (clipboard, resize). I used the SYSTEM one, 3396, because it matches the root service on Ubuntu.

### Where the tools disagree
- **Handles 400 vs file descriptors 9.** A Windows handle can point to many kinds of kernel objects: in the handles pane I saw registry keys (`Key`), `Event`, `Mutant`, `Semaphore`, `Section`, even `Thread` handles, and files. A Linux fd only points to file-like things: `/dev/null`, sockets, pipes, an eventfd and a log file. Linux has no registry and synchronises differently, so the two counts measure different things.
- **"Memory" is not the same number.** Task Manager's default column is the *private* working set (3,024 K). htop's RES (10,976 K) also counts *shared* pages — SHR is 9,332 K of it, mostly shared libraries. Process Explorer shows the same split on Windows: Working Set 13,316 K but WS Private only 2,956 K.
- **Same thing, different names:** Task Manager's **Commit size** (10,668 K) ≈ Process Explorer's **Private Bytes** (10,628 K). htop has no column for it.
- **VIRT 111M vs RES ~11M.** VIRT is all the address space the process has reserved, not memory it really uses.
- **htop shows threads as rows.** The extra green lines (PIDs 1300, 1309, 1310) are vmtoolsd's threads, with the same memory numbers because they share it. Task Manager and Process Explorer only count threads in a column.
- **Task Manager vs Process Explorer differ slightly** (402/400 handles, 14/13 threads, a few K of memory) because the screenshots were taken about a minute apart and a running service keeps opening and closing handles and threads.
- Same program, same habit: vmtoolsd keeps its log open on both systems — `C:\Windows\Temp\vmware-vmsvc-SYSTEM.log` (a File handle) and `/var/log/vmware-vmsvc-root.log` (fd 3).

## Part 2 — Memory pressure
Guest RAM: 3.3 GiB (not lowered) · swap: 2.0 GiB (`/swap.img`, file)

Steps:
1. Snapshot `before-lab6`, then `free -h` and `swapon --show`
2. Terminal 2: BEFORE block, then `while true; do echo "=== $(date +%T) ==="; free -h; sleep 3; done | tee -a memory-pressure.txt`
3. `stress-ng --vm 2 --vm-bytes 70% --timeout 60s` (~18:09)
4. `stress-ng --vm 2 --vm-bytes 90% --timeout 60s` (18:11:29) — passed
5. `stress-ng --vm 2 --vm-bytes 120% --timeout 90s` (18:13:03) — passed, nothing killed
6. `stress-ng --vm 2 --vm-bytes 200% --timeout 90s` (~18:19:35) — OOM killer
7. Ctrl+C, AFTER block, `sudo journalctl -k --since "1 hour ago" | grep -i -E -B3 -A8 "out of memory|oom-kill" > kernel-log-extract.txt`

| | Before | During (worst, 18:19:43) | After (18:24:52) |
|---|---|---|---|
| Available | 2.7Gi | 12Mi | 2.8Gi |
| Swap used | 0B | 2.0Gi (all of it) | 74Mi |

What happened (times from [memory-pressure.txt](evidence/memory-pressure.txt)):
- **70% and 90%:** available dropped to about 0.8–1.1 GiB and then ~170 Mi. Swap stayed at 0 except one sample (18:09:56: 1.5 GiB, back to 0B 3 s later). Both runs passed.
- **120% (18:13:03):** within 3 seconds available fell to ~110 Mi and **swap jumped to ~0.9–1.1 GiB** — this is where swap really started to grow. RAM + swap could still hold 3.17 GB, so stress-ng passed and nothing was killed.
- **200% (~18:19:35):** at 18:19:37 available was 82 Mi and swap 1.1 GiB; at **18:19:43 available was only 12 Mi and swap was full (2.0 GiB)**. The kernel killed the first stress-ng worker at **18:19:39**. stress-ng kept restarting its workers and the kernel kept killing them until 18:21:09; at 18:21:11 the run ended and available was back to 2.8 GiB.
- Responsiveness: during the 200% run (~18:19–18:21) the guest was lagging a bit, and switching between the terminals (Alt+F1 / Alt+F2) had problems: it was slow to respond. After the run ended at 18:21:11 it went back to normal.

Note: the BEFORE block was written at 16:02, before the recording loop and the tests; the loop kept running until 18:24, so the file is long.

### What the kernel did
From [kernel-log-extract.txt](evidence/kernel-log-extract.txt), the first kill:
```
Nov 23 18:19:39 lab01-amina kernel: stress-ng-vm invoked oom-killer: gfp_mask=0x440dc0(GFP_KERNEL_ACCOUNT|__GFP_ZERO|__GFP_COMP), order=0, oom_score_adj=1000
Nov 23 18:19:39 lab01-amina kernel: Out of memory: Killed process 12812 (stress-ng-vm) total-vm:3061244kB, anon-rss:2361360kB, file-rss:520kB, shmem-rss:16kB, UID:1000 pgtables:5964kB oom_score_adj:1000
```
- **Which process:** `stress-ng-vm`, PID 12812 — one of the two stress-ng memory workers.
- **Why that one:** it held the most memory of its own: `anon-rss:2361360kB` ≈ 2.3 GB of anonymous (private) RAM. Also `oom_score_adj:1000` is the maximum, which means stress-ng marks its own workers as "kill me first", so the kernel did not touch system processes like vmtoolsd or sshd.
- **When:** 18:19:39. This matches memory-pressure.txt: at 18:19:37 available was 82 Mi and at 18:19:43 it was 12 Mi with swap full — RAM and swap were both used up, so the kernel had to free memory by killing.
- In total the log has **13 "Killed process" lines** from 18:19:39 to 18:21:09, all `stress-ng-vm` (PIDs 12812, 12811, 12818, … 12917), because stress-ng restarted every killed worker.

### Windows
```
PS> Get-WinEvent -FilterHashtable @{LogName='System'; ProviderName='Microsoft-Windows-Resource-Exhaustion-Detector'} -MaxEvents 5 | Format-List TimeCreated, Id, Message
Get-WinEvent : No events were found that match the specified selection criteria.
```
The result is empty because I did not put memory pressure on the Windows guest, so its commit charge never came near the limit (RAM + page file). If it did, Windows would write event **2004** from Resource-Exhaustion-Detector ("Windows successfully diagnosed a low virtual memory condition") and name the processes that used the most memory. Unlike Linux, Windows does **not** kill a process: it warns, and new memory allocations simply fail, so programs may crash or show errors on their own.

## What did not work the first time
- **120% did not trigger the OOM killer.** stress-ng's percentage is of *available* memory (2.65 GB), and 3.17 GB still fit into RAM + 2 GB swap. I went to 200% (≈5.3 GB, more than RAM + swap) to get a kill.
- **The first Get-WinEvent failed** with `A positional parameter cannot be found that accepts argument '-'` because I typed `- MaxEvents` with a space. `-MaxEvents` fixed it.
- **The lab is written for VirtualBox, but I use VMware:** VBoxService does not exist, so I used vmtoolsd; snapshots are under VM → Snapshot.
- **The Ubuntu PID changed** (1238 from `pgrep` → 1237 in htop) because the VM was restarted in between, so I had to look it up again.
- **Process Explorer's lower pane took the whole window** at first and hid the process tree; I had to drag the divider down to show both.
