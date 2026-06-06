; =============================================================
; chamber_heat.g
; Chamber pre-heat routine for HevORT
; Location: macros/chamber_heat.g
; Called from: printstart.g via M98 P"/macros/chamber_heat.g" S60
;              or directly from PanelDue macro list with no parameter
;
; Parameters:
;   S = target chamber temperature in whole degrees C (e.g. S60)
;       If omitted, a popup menu is shown to select temperature
;
; Behaviour:
;   - Converts degrees to tenths and sets global.chamberSP
;   - daemon.g owns writing chamberSP to PLC R0 on its 5s poll
;   - daemon.g owns Printer_Active bit — not set here
;   - Waits until chamber PV is within 2°C of target
;   - Checks for heater fault each cycle — aborts macro if fault active
;   - Exits with warning if timeout exceeded, returns to caller
;   - Set global.chamberAbort = 1 from console to abort at any time
;   - Silent during wait — single status line on fault or timeout only
; =============================================================

; --- Setpoint selection --------------------------------------
; If called with no S parameter show a popup menu
; If called with S parameter (e.g. from printstart.g) use it directly

var targetDeg = 0

if !exists(param.S)
    M291 P"Select chamber temperature" R"Chamber Heat" S4 K{"Off","60°C","75°C"}
    if input == 0
        set var.targetDeg = 0
    elif input == 1
        set var.targetDeg = 60
    else
        set var.targetDeg = 75
else
    set var.targetDeg = param.S

; --- Validate setpoint ---------------------------------------
; Below 40°C means off — set SP to zero and exit
; Catches Off selection, slicer default of S0, or any sub-minimum value

if var.targetDeg < 40
    set global.chamberSP = 0
    M118 P0 S{"[Chamber] SP " ^ var.targetDeg ^ "°C below minimum (40°C) — heater off"}
    M99

; --- Set chamber setpoint ------------------------------------
; daemon.g will write this to PLC R0 on its next 5s poll cycle

set global.chamberSP = { var.targetDeg * 10 }
set global.chamberAbort = 0

M118 P0 S{"[Chamber] Heatup started — Target: " ^ var.targetDeg ^ "°C"}

; --- Wait loop -----------------------------------------------
; global.chamberPV — written by daemon.g from PLC R3 every 5 seconds
; global.chamberStatus — written by daemon.g from PLC R4 every 5 seconds
; Bit 3 of chamberStatus = heater fault — clears automatically when PLC clears it
; Loop polls every 5 seconds — matches daemon.g poll interval
; elapsed tracked in seconds, timeout exits loop and returns to caller
; Set global.chamberAbort = 1 from console to abort at any time

var elapsed = 0
var heaterFault = 0

while global.chamberPV < global.chamberSP - 20

    G4 P5000
    set var.elapsed = { var.elapsed + 5 }

    ; Abort check — allows external abort from console or printstart.g
    if { global.chamberAbort == 1 }
        set global.chamberAbort = 0
        set global.chamberSP = 0
        M118 P0 S{"[Chamber] Heatup aborted by user"}
        M99

    ; Heater fault check — bit 3 of Status_Bits R4
    ; Isolate bit 3 using mod arithmetic — RRF 3.6.2 has no bitwise operators
    set var.heaterFault = { mod(global.chamberStatus, 16) / 8 }

    if var.heaterFault >= 1
        M118 P0 S{"[Chamber] Heater fault reported by PLC — aborting heatup"}
        set global.chamberSP = 0
        M99

    ; Timeout check
    if var.elapsed >= 3600
        M118 P0 S{"[Chamber] Timeout reached (3600s) — continuing anyway"}
        break

; --- Complete ------------------------------------------------

M118 P0 S{"[Chamber] Ready — " ^ global.chamberPV/10 ^ "°C"}