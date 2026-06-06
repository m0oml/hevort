; ======================================================================================
; Chamber Variables - vars.g
; Initialises global state for PLC Modbus communication
; Called from config.g at startup and by daemon.g if globals are missing
; ======================================================================================

; --- Chamber Setpoint (tenths °C, e.g. 500 = 50.0°C) ---
global chamberSP = 0

; --- Chamber Process Value (tenths °C, read from PLC) ---
global chamberPV = 0

; --- Heartbeat Counter (0-32767, increments each daemon cycle) ---
global chamberHeartbeat = 0

; --- Status Bits from PLC (R4) ---
;   Bit 0 = Chamber sensor fault
;   Bit 1 = Top sensor fault
;   Bit 2 = Bottom sensor fault
;   Bit 3 = Heater fault
;   Bit 4 = PLC heartbeat toggle
;   Bit 5 = PLC running
;   Bit 6 = Duet comms OK
;   Bit 7 = Duet comms fault
global chamberStatus = 0

; --- Control Bits to PLC (R2) ---
;   Bit 0 = Printer_Active (set when printing/paused)
global duetControl = 0

; --- PLC Register Read Buffer ---
global plcRegs = {0,0,0,0,0}
