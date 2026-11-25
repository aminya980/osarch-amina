# Builds — four machines, four loads

All four machines use the same **platform** (AMD AM5 socket, B650 chipset, DDR5,
NVMe M.2 PCIe 4.0). The platform is shared so that spare parts, drivers and
upgrades are interchangeable and AM5 can take newer Ryzen CPUs later.
What differs between the machines is **where the money goes** — to each
person's bottleneck.

Prices and links: [budget.csv](budget.csv). Compatibility and power checked in
PCPartPicker: [evidence/pcpartpicker-links.md](evidence/pcpartpicker-links.md).

### Build 1 — accountant

**Load:** 1C:Enterprise (Kazakhstan configuration), Excel with large ledgers,
the bank client and the tax portal (cabinet.salyk.kz) in a browser — 8 hours a
day, 3–4 programs open at once, constantly comparing two documents side by side.
**Bottleneck:** not CPU, not GPU — **the screen and reliability**. 1C + Excel +
browser fits in ~8–10 GB, so 16 GB never swaps. What hurts this person is a
small screen (scrolling between a ledger and a bank statement all day) and lost
data: a power cut during a 1C write can corrupt the infobase, and accounting
data cannot be lost.
**Trade-off:** took the cheapest AM5 CPU with integrated graphics
(Ryzen 5 8500G, no graphics card) and only 16 GB (2×8 GB) instead of 32 GB.
The ~60,000 KZT saved went into a **27" QHD IPS monitor** (two documents side by
side) and a **UPS** so the PC shuts down cleanly when the power goes. The
alternative I did not take: a Ryzen 7 / 32 GB — the CPU would idle at 5–10 %
all day. Memory can be added later (two free slots).
**OS:** Windows 11 Pro — 1C and the Kazakh bank clients / NCALayer (ЭЦП) run
on Windows; Pro gives BitLocker to encrypt the financial data.
**Total:** see `accountant,TOTAL` in budget.csv (~539,000 KZT)

### Build 2 — sales manager

**Load:** CRM in a browser, 30–40 tabs, Excel, WhatsApp Web / Telegram, about
four hours of video calls a day (Zoom / Google Meet), often all at once.
**Bottleneck:** **memory**, not CPU. Chrome with forty tabs plus a video call
is around 11–12 GB; with Windows on top, 16 GB is at the limit and the machine
starts swapping in the middle of a customer call (Lab 6 — swapping). The second
bottleneck is **camera and audio**: a client hears and sees the headset and
webcam, not the CPU.
**Trade-off:** took a Ryzen 5 8500G (6 cores, integrated graphics) instead of a
Ryzen 7 and spent the difference on **32 GB (2×16 GB)** instead of 16 GB, plus a
webcam and a headset with a microphone. A 24" Full HD monitor instead of 27" —
this person mostly reads one CRM window. Alternative not taken: 16 GB and a
faster CPU — the CPU idles in this role; the memory does not.
**OS:** Windows 11 Pro (Office, corporate standard, BitLocker for the client base).
**Total:** see `sales,TOTAL` in budget.csv (~466350 KZT)

### Build 3 — web developer

**Load:** VS Code, Docker / docker-compose with 4–6 containers (app, PostgreSQL,
Redis, nginx), a local database, 2–3 browsers for testing with DevTools, and
sometimes a VM — 8–10 hours a day, all at the same time.
**Bottleneck:** **memory first, then CPU cores**. Each container and the
database hold their own memory; Docker + a DB + two browsers + VS Code is
18–24 GB. On 16 GB the machine swaps during every build. Builds and container
restarts then load all cores, so 8 cores matter more here than anywhere else.
**Trade-off:** no graphics card (iGPU is enough for code), and **Ubuntu 24.04
LTS instead of Windows** — that saves ~95,000 KZT, which paid for the 8-core
Ryzen 7 7700 and the fast Gen4 SSD. Took 32 GB now, not 64 GB, but on a board
with **4 memory slots** so 2×16 GB more can be added later without throwing
anything away. Alternative not taken: 64 GB now with a Ryzen 5 — over budget
for today's DDR5 prices, and an upgrade later is cheap.
**OS — why Linux is licensed and suitable:** Ubuntu is free and open-source
(GPL and other free licences) — using it commercially is fully legal and costs
0 KZT; LTS support runs to 2029 (and 2034 with Ubuntu Pro, free for up to 5
machines). The company's sites will be deployed on Linux servers, and Docker
runs natively on Linux (no WSL2 overhead), so the developer works in the same
environment as production.
**Total:** see `webdev,TOTAL` in budget.csv (~682,460 KZT)

### Build 4 — designer

**Load:** Adobe Photoshop and Illustrator with large multi-layer files
(300–800 MB PSD, print layouts), Figma in a browser, sometimes short video in
Premiere Pro — 8 hours a day, 2–3 heavy apps open.
**Bottleneck:** **the monitor (colour accuracy) and memory**, then the GPU.
If the screen is not colour-accurate, every print and every banner comes out
in the wrong colours — no CPU fixes that. Large PSD files plus Illustrator use
20+ GB of memory, and Photoshop/Premiere use the GPU for filters, scaling and
video export (Adobe supports NVIDIA GPU acceleration best).
**Trade-off:** took a Ryzen 5 7600 (6 cores) instead of a Ryzen 7 and put the
money into a **factory-calibrated 27" QHD IPS monitor (100 % sRGB, ΔE < 2)** and
an **RTX 5060 8 GB** graphics card. This is the most expensive machine on
purpose: it is the only role where the screen and GPU are the job. Alternative
not taken: a 4K wide-gamut (Adobe RGB) monitor — ~350,000 KZT+, would break the
budget; for web and most print work sRGB is enough. Memory: 32 GB now, 4 slots
for 64 GB later.
**OS:** Windows 11 Pro — Adobe Creative Cloud does not run on Linux.
**Total:** see `designer,TOTAL` in budget.csv (~1,096,660 KZT)

## Compatibility check (same rules as Lab 3)

| Check | Accountant | Sales | Web dev | Designer |
|---|---|---|---|---|
| CPU socket ↔ board | AM5 ↔ AM5 | AM5 ↔ AM5 | AM5 ↔ AM5 | AM5 ↔ AM5 |
| Board memory ↔ RAM | DDR5 ↔ DDR5 | DDR5 ↔ DDR5 | DDR5 ↔ DDR5 | DDR5 ↔ DDR5 |
| M.2 slot ↔ SSD | M.2 PCIe 4.0 ↔ NVMe | M.2 PCIe 4.0 ↔ NVMe | M.2 PCIe 4.0 ↔ NVMe Gen4 | M.2 PCIe 4.0 ↔ NVMe Gen4 |
| Est. power ↔ PSU | ~130 W ↔ 550 W | ~130 W ↔ 550 W | ~170 W ↔ 650 W | ~330 W ↔ 650 W |
| Graphics | iGPU (Radeon 740M) | iGPU (Radeon 740M) | iGPU (Radeon 610M) | RTX 5060 |

Note: Ryzen 8000G CPUs need a B650 BIOS from 2024 or newer (AGESA 1.1.0.0+);
current retail boards ship with it — confirm "8000G support" on the board page.