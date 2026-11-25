# Ticket 2 — Kitting out the new office

## 1. What was asked

> **From:** Daniyar K. (Director)
> **Subject:** computers for the new office
>
> We are opening the second office and need four computers — accountant, sales,
> web developer, designer. Budget 3,000,000 tenge for everything. Everyone says
> we should just buy the same four machines, is that right? Make sure they last
> a few years. Monitors included.

## 2. What was actually needed

**Four identical machines is the wrong answer.** The four people put four
different loads on a computer, and each load runs out of a different resource
first:

| Role | What runs out first |
|---|---|
| Accountant | the screen and reliability (data must not be lost) |
| Sales | memory (browser tabs + video calls) and the camera/audio |
| Web developer | memory, then CPU cores (containers, DB, builds) |
| Designer | monitor colour accuracy, memory, GPU |

If we buy four identical machines, we have two bad options. Either all four
are built for the designer (~1,100,000 KZT each = 4.4 M — over budget, and the
accountant gets a graphics card she will never use), or all four are built
for the accountant (~540,000 KZT) and the designer gets a screen with wrong
colours and no GPU, and the developer swaps all day. Identical machines spend
money where it is not needed and starve the roles that need it. What **is**
worth keeping the same is the **platform** (AM5, DDR5, same SSD and PSU
family): one set of spares, one set of drivers, same upgrade path.

**What the request left out**

- **Operating system licences** — Windows 11 Pro OEM is ~46,900 KZT per machine.
- **Keyboard, mouse**, and for sales a **webcam and headset** (4 h of calls a day).
- **UPS** for the accountant — a power cut during a 1C write can damage the database.
- **Software** — 1C, MS Office / Microsoft 365, Adobe Creative Cloud are
  subscriptions/licences, not hardware, and are *not* in this budget.
- **Backups** — nothing in the request says where accounting data is backed up.
- **Network** — router, cables, Wi-Fi in the new office.
- **Delivery, assembly, warranty** — who builds and who services the machines.

**What I would ask Daniyar → what I assumed instead**

| Question to Daniyar | What I assumed |
|---|---|
| Does 3,000,000 KZT include software (1C, Office, Adobe)? | No — hardware + OS + monitors + peripherals only; software is a separate budget. |
| "A few years" — how many? | 4–5 years, so I chose AM5 + DDR5 (CPU and memory can be upgraded instead of replacing the PC). |
| What software does each person use? | Accountant: 1C + Excel + bank client (Windows only). Sales: browser CRM + Zoom. Developer: Docker, VS Code, PostgreSQL. Designer: Photoshop, Illustrator, Figma. |
| Does the designer work for print or for screen? | Mostly web/social media + some print → sRGB-calibrated monitor is enough; no Adobe RGB. |
| Does the developer need Windows for anything? | No — he deploys to Linux servers → Ubuntu LTS. |
| Is there a network/backup/server already? | No — I added a UPS for the accountant and listed backups as a next step. |
| Do they want desktops or laptops? (sales may travel) | Desktops — the request says "computers" for an office. |
| Can we spend all 3 M, or should there be a reserve? | Keep ~215,350 KZT in reserve: DDR5 and SSD prices in KZ move quickly, and the reserve covers backup storage and network. |

## 3. What I did

1. Wrote **Load → Bottleneck → Trade-off** for each role *before* choosing parts.
2. Picked one shared platform (AM5 / B650 / DDR5 / NVMe) for spares and upgrades.
3. Put the money into each role's bottleneck: monitor + UPS for the accountant,
   32 GB + webcam/headset for sales, 8 cores + 32 GB + Linux for the developer,
   calibrated monitor + GPU for the designer.
4. Checked compatibility (socket, memory type, M.2, power) in PCPartPicker.
5. Took prices in tenge from vendors that deliver in Kazakhstan, with the date.

Details: **[builds.md](builds.md)** · Prices: **[budget.csv](budget.csv)**

| Role | Total (KZT) |
|---|---:|
| Accountant | 539,215 |
| Sales | 466,315 |
| Web developer | 682,460 |
| Designer | 1,096,660 |
| **Grand total** | **2,784,650** |
| Reserve (of 3,000,000) | 215,350 |

Every machine: ≥ 16 GB memory, 1 TB NVMe SSD, licensed OS (Windows 11 Pro, or
Ubuntu LTS for the developer — free GPL licence), one monitor.

### Q1. Which machine will you upgrade first, eighteen months from now, and why?

**The web developer's — memory, from 32 GB to 64 GB.** Projects grow: more
containers, a bigger database, more services in docker-compose, and maybe a
VM for testing. Memory is already his bottleneck and it is the first thing
that will run out. I chose a board with **4 DIMM slots** on purpose, so the
upgrade is just adding another 2×16 GB DDR5 kit (~120,000 KZT today) — nothing
is thrown away. Second candidate: the accountant's memory (16 → 32 GB) if
1C databases grow.

### Q2. Pre-built machines from a vendor — what do we gain and lose?

| Role | Comparable pre-built (closest match) | Price (KZT) | Source | Date |
|---|---|---:|---|---|
| Accountant | Lenovo ThinkCentre / HP Pro office desktop, Ryzen 5 / Core i5, 16 GB, 512 GB SSD, Win 11 Pro + same monitor & UPS | _fill in_ | _link_ | 2026-11-25 |
| Sales | same office desktop + 32 GB upgrade + monitor, webcam, headset | _fill in_ | _link_ | 2026-11-25 |
| Web dev | HP / Lenovo desktop, Ryzen 7 / Core i7, 32 GB, 1 TB + monitor | _fill in_ | _link_ | 2026-11-25 |
| Designer | "creator"/gaming desktop with RTX 5060 / 4060, 32 GB, 1 TB + ProArt monitor | _fill in_ | _link_ | 2026-11-25 |

**What the company gains:** one warranty from one vendor (often 1–3 years,
on-site for business lines), the machine arrives assembled and tested, no time
spent building, one invoice for accounting, Windows pre-installed and licensed.

**What it loses:** choice of parts — office pre-builts usually come with
8–16 GB, a 256–512 GB SSD and a slow single memory stick, so the sales and
developer machines would need upgrades right away (and opening the case can
void some warranties); a weaker or proprietary PSU and motherboard (no free
DIMM slots, no GPU slot) — **a worse upgrade path**; and usually a higher price
for the same performance (I expect +15–30 %). A reasonable middle ground:
buy the accountant and sales machines pre-built (simple loads, warranty
matters most), build the developer and designer machines (loads are specific).

### Q3. Who will complain about performance within a month, and about what?

**The designer — about Photoshop/Premiere with very large files.** I gave her
a 6-core Ryzen 5 7600 instead of a Ryzen 7, and an RTX 5060 with only **8 GB of
video memory**. When she opens a multi-gigabyte print layout or exports a 4K
video in Premiere, the export will be slow and Photoshop may warn about GPU
memory. The fix is cheap and was planned: the AM5 board takes a Ryzen 7/9 and
there are two free memory slots for 64 GB. (Second guess: the sales manager
will complain that the 24" screen is small for CRM + a video call side by side.)

## 4. Evidence

- [evidence/pcpartpicker-links.md](evidence/pcpartpicker-links.md) — one
  PCPartPicker list per build; proves the parts are compatible (socket, DDR5,
  M.2) and the PSU covers the estimated power. PCPartPicker does not price in
  tenge — it was used **only for compatibility and power**.
- [evidence/vendor-quotes/](evidence/vendor-quotes/) — a screenshot of every
  price in budget.csv, with the vendor's address bar and the date visible;
  proves each price is real, in KZT, from a vendor that delivers in Kazakhstan,
  on the date given.
- [budget.csv](budget.csv) — every part, price, vendor link and date; totals
  per role and grand total ≤ 3,000,000 KZT.

## 5. What I would do differently

- I would **ask Daniyar the questions in section 2 before buying** — especially
  whether 1C, Office and Adobe are in the same 3,000,000 KZT. If they are,
  Adobe CC + Microsoft 365 for four people take ~400,000 KZT/year and I would
  have to cut the designer's GPU first.
- I would spend part of the 215,350 KZT reserve on **backups**: a small NAS or
  external disk for the accountant's 1C database (a UPS protects against power
  cuts, not against a dead SSD or ransomware).
- I would **take all prices on one day from one or two vendors** and screenshot
  them as I went — collecting quotes at the end is when mistakes happen.
