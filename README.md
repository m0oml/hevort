

# HevORT Build — Project Brief for Claude

## About This Project
Large-format HevORT 3D printer build. 415×415×440mm print volume. Currently in electronics bay wiring phase — panel wired, 50-core umbilical terminals being landed.

---

## Working Style
- Direct and technically precise. No hand-holding.
- Prefer one step at a time — don't get ahead.
- Prefer changed blocks over full file dumps unless asked.
- Catch errors immediately and correct confidently.
- Hardware fixes preferred over software workarounds.
- Rigorous source criticism — do not cite unreliable sources.
- `docker compose` not `docker-compose`. File is `docker-compose.yml` not `.yaml`.

---

## Session Bootstrap
At the start of each session fetch from Google Drive Hevort folder:
- HevORT_Project_Brief.md (this file)
- duet_config/config.g
- duet_config/daemon.g

---

## Printer Hardware Specification

| Item | Detail |
|---|---|
| Build volume | 415 × 415 × 440 mm |
| Gantry | HD12 SPAWD AWD |
| Belts | 12mm 2GT Gates EPDM |
| Pulleys | 20T GT2 |
| X beam | 20×20×2mm CF tube |
| X/Y rails | MGN12H 550mm |
| Z axis | ZR V2.6, SFU1204 ball screws, WobbleX WS12 isolators |
| Z motors | 42HSB47A41505 brake steppers (79mm, 60 Ncm, 24V brake, 1.5A) — power to release |
| XY/AWD motors | M23CL-76-2804 (18.9 kg/cm, 0.48 kg/cm² rotor inertia) on CAN-FD, assisted open-loop (D3) |
| Motion controller | Duet 3 6HC v1.02c standalone, RRF 3.6.2 |
| Toolhead | Mellow CNC Vz-HextrudORT water-cooled, Goliath hotend |
| Extruder | NEMA14 |
| Endstops | Omron EE-SX67x optical (physical, not sensorless) |
| Umbilical | 50 cores — HIGH block 29 cores, LOW block 21 cores |
| SBC | Raspberry Pi 4 |
| Display | Waveshare DSI — undecided size, 10.1" preferred candidate |

### AWD Motor Layout (top-down, front at bottom)
| | Left | Right |
|---|---|---|
| **Back** | 73.0 Y2 | 70.0 X1 |
| **Front** | 71.0 X2 | 72.0 Y1 |

---

## Chamber Heating System

| Item | Detail |
|---|---|
| Heater | 1400W PTC with shaded-pole motor |
| Heater contactor | K1 — two-pole |
| SSR1 / SSR2 | ENMG SDR25A2032 25A |
| K2 | Fan relay |
| K3 | PLC safety pilot relay — 2-pole, coil driven by Duet OUT8 |
| PLC | Siemens S7-1200 CPU 1212C DC/DC/Rly, FW V4.3, TIA Portal V15.1 Update 8 |
| RTD module | SM1231 8-channel — Slot 2, addresses IW96–IW110 |
| RS485 module | CB1241 RS485, hardware ID 269, MODE=4 in DB2 |
| HMI | Siemens KTP700 Basic PN, single screen, status indicators only (no SP input, no alarm screen) |
| PROFINET switch | Helmholz 700-850-4PS01 managed switch — configured in TIA Portal, in project |

---

## PROFINET Network

Subnet: 192.168.32.0/24, mask 255.255.255.0, no router.

| Device | IP Address | PROFINET name | Notes |
|---|---|---|---|
| PLC_1 (S7-1212C) | 192.168.32.70 | plc_1 | Set in project |
| KTP700 HMI | 192.168.32.71 | — | |
| Helmholz PN Switch | 192.168.32.72 | — | Port 1=PLC, Port 2=HMI, Port 3=Pi, Port 4=uplink |
| NTP Server 1 | 192.168.32.1 | — | Router/gateway |
| NTP Server 2 | 192.168.32.5 | — | |

Windows Firewall on TIA Portal PC must have exception for TIA Portal or be disabled when programming.

---

## Safety Circuit — Duet → PLC Relay (K3)

Duet OUT8 drives K3 coil directly. HIGH = relay energised = system healthy. Drops on any Duet stop/estop.

- **K3 Pole 1 NO** → PLC %I0.0 (DI_EStop_PLC) — 24V when relay energised
- **K3 Pole 2 NO** → spare (TBD)
- **No SR latch in PLC** — %I0.0 is used directly in FC4. Duet OUT8 is the only latch mechanism.
- Duet OUT8 asserted HIGH in config.g at startup. Drops via `M42 P0 S0` in sleep.g, trigger0.g, trigger3.g.
- OUT8 does **not** drop on M0 (end of print) — only on genuine stop/estop.

---

## Modbus RTU — Duet ↔ PLC

- **Physical layer:** Duet 3 6HC onboard RS485 transceiver (v1.02c onwards). RS485_EN jumper fitted. IO1 dedicated — do not use IO1 for anything else.
- **Cable:** OSP1 1×2×24AWG overall screened, drain grounded at PLC end only, 260mm run — no termination resistor needed
- **Duet config:** `M575 P2 B9600 S7`
- **Protocol:** 9600 8N1, Duet = master, PLC CB1241 = slave address 1
- **Polling:** daemon.g reads all 5 registers every 5 seconds using `M261.1 F3 R0 B5`
- **Note:** RRF 3.6.2 has **no bitwise operators** — use mod arithmetic for bit extraction

### Register Map (DB1, HR40001 base)

| R# | Name | Direction | Format |
|---|---|---|---|
| R0 | Chamber_SP | Duet → PLC | Int, tenths °C |
| R1 | Duet_Heartbeat | Duet → PLC | Int, 0–32767 |
| R2 | Duet_Control_Bits | Duet → PLC | Bit0 = Printer_Active (from state.status) |
| R3 | Chamber_PV | PLC → Duet | Int, tenths °C |
| R4 | Status_Bits | PLC → Duet | See below |

### Status_Bits (R4)
| Bit | Meaning |
|---|---|
| 0 | Chamber sensor fault |
| 1 | Top sensor fault |
| 2 | Bottom sensor fault |
| 3 | Heater fault |
| 4 | PLC heartbeat toggle |
| 5 | PLC running |
| 6 | Duet comms OK |
| 7 | Duet comms fault |

---

## PLC Program Structure (OB1 + OB30)

| Network | Function |
|---|---|
| N1 | MB_COMM_LOAD (REQ=FirstScan, PORT=269, BAUD=9600, PARITY=0, MODE=4 in DB2) |
| N2 | MB_SLAVE (addr=1, MB_HOLD_REG=P#DB1.DBX0.0 BYTE 10) |
| N3 | FC1 Chamber_Temp_Calc — weighted RTD avg (50/25/25%), fault exclusion → %MD30, %MW44 |
| N4 | FB1 FB_Chamber_Comms — Status_Bits assembly, Duet watchdog (10000 scan threshold) |
| N5 | FC2 Electronics_Cooling — elec bay fan on/off, temp hysteresis 35–40°C, always on when printer active |
| N6 | FC3 AirOff_Sensor — sensor validation, RTD_AirOff → %MD36 |
| N7 | FC4 FC_Safety — %I0.0 direct (no latch), Heater_Enable all conditions, PID_Clamp, Fans_MinSpeed, Heater_Fan |
| N8 | Chamber heater fault — live assignment, no latch: Chamber_HeaterFault := Chamber_Heater_Fault_Trig |
| N9 | REAL_TO_INT Temp_Chamber_PV × 10 → Modbus_Registers.Chamber_PV |
| OB30 N1 | FC6 FC_SP_Convert — Modbus tenths → Real °C, clamped 0–120°C |
| OB30 N2 | PID_Compact_1 (DB5) — outer loop, EN=Chamber_Heat_En, PV=Chamber_PV, SP=Chamber_SP_Real |
| OB30 N3 | FB2 FB_AirOff_Scale — outer PID output → inner SP, safety cut |
| OB30 N4 | PID_Compact_2 (DB6) — inner loop, EN=Chamber_Heat_En, PV=AirOff_PV, SP=Inner_SP_Real |
| OB30 N5 | FC5 FC_Heater_Output — PID output → Int 0–100, zeroes when not enabled |
| OB30 N6 | FC7 FC_Heater_PWM — time-proportioning SSR drive, 2s cycle, output → Chamber_Heat_SSR |

### SM1222 Output Map (Slot 3, DQ 8x24VDC, base %QB12)
| Address | Tag | Function |
|---|---|---|
| %Q12.0 | Chamber_Heat_En | K1 contactor coil |
| %Q12.1 | Chamber_Heat_Fan | K2 fan relay coil |
| %Q12.2 | Chamber_Heat_SSR | Chamber heater SSR (SSR1/SSR2) |
| %Q12.3 | Bay_Fans | Elec bay fan relay |
| %Q12.4–7 | — | Spare |

All CPU relay outputs (Q0.x) are spare — no loads assigned.

### Key PLC Tags
| Tag | Address | Description |
|---|---|---|
| Temp_Chamber_PV | %MD30 | Weighted chamber average (Real, °C) |
| Temp_Sensor_Fault | %MW44 | Sensor fault word |
| Temp_AirOff_PV | %MD36 | Air-off temperature (Real, °C) |
| Chamber_SP_Real | %MD50 | Chamber setpoint (Real, °C) |
| Outer_PID_Output | %MD54 | Outer PID output |
| Inner_SP_Real | %MD58 | Air-off setpoint from outer PID |
| Inner_PID_Output | %MD62 | Inner PID output |
| Heater_Output | %MW42 | Heater demand 0–100 Int |
| Heater_Cycle_Count | %MW46 | FC7 PWM cycle counter |
| PID_Clamp | %M22.3 | |
| Duet_Comms_OK | %M22.4 | |
| AirOff_SafetyCut | %M22.5 | |
| AirOff_Valid | %M22.0 | |
| Chamber_HeaterFault | %M20.1 | Live (no latch) |
| Chamber_Active | %M20.3 | |
| Chamber_Estop | %M20.0 | NOT %I0.0 — relay to Duet status |
| Chamber_Heater_Fault_Trig | %M20.4 | Live fault trigger |
| Cooling_PrinterOn | %M21.1 | Fans minimum speed flag |
| DI_EStop_PLC | %I0.0 | Duet OUT8 → K3 pole 1 → PLC input |

---

## Duet IO Map

### Output Ports
| Port | Assignment | Notes |
|---|---|---|
| OUT0 | Hotend heater | 15A, highest rated |
| OUT1 | Elec bay fans ×2 series | PWM 500Hz, MCU/driver thermostatic |
| OUT2 | Available | |
| OUT3 | Z brakes (commoned, 24V) | Power to release. Auto via M569.2 |
| OUT4 | Duet enclosure fan (Noctua NF-A4x10 24V PWM) | Off <40°C, 100% at 60°C, MCU+driver temp |
| OUT5 | WS7040 CPAP (part cooling) | Manual/slicer, tach on out5.tach |
| OUT6 | Water pump PWM | Gated by hotend >50°C in daemon.g. 40% at 25°C coolant, 100% at 40°C |
| OUT7 | Bed heater SSR gate | Low-side switched |
| OUT8 | PLC safety relay K3 coil | HIGH = healthy. Drops on stop/estop only (not M0 end of print) |

### IO Ports
| Port | Assignment | Notes |
|---|---|---|
| IO1 | RS485 Modbus | Reserved, RS485_EN jumper fitted |
| IO2 | X endstop | Omron EE-SX67x, homes to max (right) |
| IO3 | Y endstop | Omron EE-SX67x, homes to min (front) |
| IO4 | Z probe | Digital probe |
| IO5 | Flow switch | NC — closed = flow present |
| IO6 | Filament sensor | TBD — placeholder, commented out |
| IO7 | Available | |
| IO8 | Pause button | NO — make to pause, during print only |
| IO9 | Stop button | NC — break to stop |

### Temperature Inputs
| Port | Assignment | Sensor |
|---|---|---|
| TEMP0 | Hotend | PT1000 (as supplied with Goliath) |
| TEMP1 | Bed interior | 100K NTC B3950 — PID source for H0 |
| TEMP2 | Bed heater mat surface | 100K NTC B3950 — safety limit 125°C on H0 |
| TEMP3 | Coolant (cold side, post-rad) | Alphacool Eiszapfen flat G1/4, NTC 10K B3950, acetal body |
| S10 | MCU temp | Requires cold-start calibration before use |
| S11 | Driver temp | Binary states only: 0/100/130°C |

### Stepper Drivers
| Driver | Assignment |
|---|---|
| 0.0 | Z0 |
| 0.1 | Z1 |
| 0.2 | Z2 |
| 0.3 | Available |
| 0.4 | Available |
| 0.5 | Extruder |
| 70.0 | X1 (CAN, back-right) |
| 71.0 | X2 (CAN, front-left) |
| 72.0 | Y1 (CAN, front-right) |
| 73.0 | Y2 (CAN, back-left) |

---

## Duet Files

| File | Purpose |
|---|---|
| config.g | Full machine config — see duet_config/ in Drive |
| vars.g | Globals: chamberSP=0, chamberPV=0, chamberHeartbeat=0, chamberStatus=0, duetControl=0, plcRegs=null |
| daemon.g | Polls PLC every 5s, writes R0–R2, reads R3–R4, gates water pump and elec bay fans on hotend temp |
| sys/trigger0.g | Flow switch loss → M42 P0 S0 + M112 |
| sys/trigger2.g | Pause button → M25 |
| sys/trigger3.g | Stop button → M42 P0 S0 + M0 |
| sys/sleep.g | Any M112 → M42 P0 S0 |
| sys/stop.g | Any M0 → no action (OUT8 not dropped on normal stop) |
| macros/chamber_heatup.g | Completed |
| macros/printstart.g | Outstanding — needs chamber setpoint handling |
| macros/printend.g | Outstanding |

---

## Power Supplies

| PSU | Model | Rating | Rail |
|---|---|---|---|
| T1 | Meanwell LRS-450-24 | 450W / 18.8A | +24V printer (SSRs, relays, motors 24V brake) |
| T2 | Meanwell LRS-450-48 | 450W / 9.4A | **+48V motors only** — no other loads on this rail |
| T3 | Meanwell MDR-60-5 | 60W / 12A | +5V always-on (Duet EXT_5V, Pi 4/SBC, display) |
| T4 | Meanwell MDR-60-24 | 60W / 2.5A | +24V control always-on (PLC L+, KTP700) |

---

## AC Mains Distribution

| Ref | Rating | Type | Load |
|---|---|---|---|
| F2 / MCB1 | 6A C | MCB | Bed heater SSR |
| F3 / MCB2 | **13A C** | MCB | Chamber heater — **must remain 13A** |
| F4 / MCB3 | 10A C | MCB | Printer PSUs (T1 LRS-450-24, T2 LRS-450-48) |
| F5 / MCB4 | 6A B | MCB | Always-on PSUs (T3 MDR-60-5, T4 MDR-60-24) |

---

## DC Fuse Schedule

**MDR-60-5 (5V) — 1 fuse**
- 3.15A: Duet 3 6HC logic + Pi 4/SBC

**MDR-60-24 (24V control) — 5 fuses**
- 3A: S7-1212C CPU + SM1231 RTD + CB1241 RS485
- 3A: SM1222 DQ8 transistor module L+
- 3A: Relay output module L+
- 500mA: Helmholz managed switch
- 3A: KTP700 HMI

**LRS-450-48 (48V) — 4 fuses via TDB**
- 3A per motor port × 4 (Duet Tool Distribution Board)
- No upstream DC fuse — MCB3 on AC primary provides installation protection

**Total: 10 fuse carriers**

---

## DC Wiring Colour Standard (BS 7671:2018 / BS EN 60204-1:2018)

| Circuit | Colour | Notes |
|---|---|---|
| AC Line (L) | Brown | Mandatory |
| AC Neutral (N) | Blue + brown heatshrink band at each end | Blue wire, brown band distinguishes from DC 0V |
| AC PE | Green/Yellow | Mandatory |
| All DC positive (+5V, +24V, +48V) | Red | Labelled at every termination (+5V / +24V / +48V) |
| All DC negative / 0V | White | H07V-K 1×1.5mm² white — unambiguous, no conflict with AC colours |

- Cable: H07V-K 1×1.5mm² throughout panel
- All PSU 0V negatives bond to a common earth block alongside PE — single earth reference point for all DC

---

## Electronics Bay Layout (v5)

**Face panel (570mm wide, 900mm tall) — outer face of right side panel (5mm aluminium):**
- Zone D (0–170mm, top): CPAP blower left, umbilical entry right-justified
- Zone C (170–290mm): Belt path clear top 80mm; PLC top horizontal duct at 250–390mm
- Zone B (290–400mm): S7-1212C PLC between motor towers (80mm each side), vertical ducts either side
- Zone A (400–900mm): Pi 4 + Duet 3 6HC (in printed enclosure with Noctua NF-A4x10 fan) + TDB (top); mains DIN rail: MCBs, MDR-60-24, MDR-60-5, relay, contactor, SSR bed, SSR chamber (bottom)

**Rear panel (250mm deep):**
- Top: 240mm radiator (Alphacool ES T38) + 2× exhaust fans (120mm 12V PC fans in series on 24V, PLC controlled via Bay_Fans relay %Q12.3)
- Middle: Clear
- Bottom: LRS-450-24 + LRS-450-48 mounted flat (225×124×35mm each, side by side)

**Cable trunking:** 40×80mm slotted, ~2,690mm total

---

## Water Cooling Loop

- **Water block:** Mellow CNC Vz-HextrudORT WC (motor, heatbreak, Goliath cold zone)
- **Loop order:** Pump outlet → Goliath block → NEMA14 motor plate → rad top in → rad bottom out → reservoir → pump
- **Design:** Self-bleeding — highest point is rad top, air purges on fill
- **Pump:** Xylem Lowara D5 PWM (Alphacool Eisbecher Lite 250mm acetal reservoir mounts directly on pump)
- **Rad:** Alphacool ES Aluminium 240mm T38 — spare G1/4 port used for coolant temp sensor
- **Coolant temp sensor:** Alphacool Eiszapfen flat G1/4, NTC 10K B3950, acetal body — TEMP3 on Duet, B3950
- **Fittings (4mm):** John Guest PM010821E (G1/4 × 4mm acetal) — **DO NOT substitute PM010411E**
- **Fittings (10mm):** John Guest PM011421E (G1/4 × 10mm acetal) — rad outlet to res
- **Toolhead ports:** SMC KQ2VS04-M5A swivel fittings at M5 block ports
- **Tubing:** 4mm OD silicone (toolhead circuit), 10mm OD silicone (static rad-to-res section)
- **Coolant:** Mayhems X1 Clear Premix — **aluminium-safe only; no copper/brass in wetted path; no pastel coolants**
- **Pump control:** Duet OUT6, PWM. Gated by hotend temp in daemon.g — off below 50°C hotend, 40% min at 25°C coolant, 100% at 40°C coolant

---

## Schematics Status (QElectroTech)

- **Sheet 1 (Mains AC Distribution):** .qet generated, may need element relinking in QET
- **Sheet 2 (DC Distribution):** Not yet completed

---

## Outstanding Work

1. Land all 50 umbilical terminals on bench
2. Fit panel to machine
3. Post-fit wiring: electronics bay cooling fans (direct wire, no terminal blocks), water loop electrical signals, flow switch (Duet IO5 — TBD NC/NO once sourced)
4. MCU temperature sensor cold-start calibration
5. CAN address assignment and encoder calibration for 4× M23CL-76-2804 motors when they arrive
6. PID autotune — hotend and bed once physically wired
7. Input shaper tuning — accelerations currently placeholder (500 mm/s²)
8. printstart.g and printend.g — chamber setpoint handling
9. QElectroTech Sheet 2 — DC distribution
10. White H07V-K 1.5mm² ordered — DC 0V wiring to complete once arrived
11. Brown heatshrink ordered — AC neutral identification bands to fit
12. HMI — review Temp_Fan_PWM and Fan_Cycle_Count references now FC8 removed; Cooling_FanActive and Cooling_TempFault tags review
13. Replace old PLC PDF in project files with plc_dump_v2.pdf (compact, text-extractable version)
14. ~~PROFINET switch configured in TIA Portal~~ **DONE** — Helmholz 700-850-4PS01 added to project, IPs assigned, downloaded to PLC 05/06/2026
15. ~~PLC firmware mismatch (V4.2 project vs V4.3 CPU)~~ **DONE** — HSP0276 installed, project updated to V4.3, download successful 05/06/2026
16. ~~Safety circuit~~ **DONE** — Duet OUT8 → K3 → %I0.0, FC4 updated, trigger macros written, stop.g/sleep.g complete
17. ~~FC2 Electronics_Cooling~~ **DONE** — rewritten, simple on/off thermostat 35–40°C hysteresis + printer active override, Bay_Fans %Q12.3
18. ~~SM1222 output rationalisation~~ **DONE** — all chamber/bay loads on transistor module, clean tag names, FC8 removed
19. ~~FC4 FC_Safety SR latch~~ **DONE** — latch removed, EStop_HW used directly, Safety_Relay output removed
20. ~~OB1 Network 8 heater fault latch~~ **DONE** — replaced with live assignment

