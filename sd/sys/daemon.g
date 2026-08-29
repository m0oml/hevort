; ======================================================================================
; Daemon Script - HevORT Chamber PLC Communication
; Polls Siemens S7-1200 via Modbus RTU over RS485, once per invocation.
;
; Register Map (Holding Registers):
;   R0 = Chamber_SP         (Duet->PLC, tenths degC)
;   R1 = Duet_Heartbeat     (Duet->PLC, 0-32767)
;   R2 = Duet_Control_Bits  (Duet->PLC, bit 0 = Printer_Active, see vars.g)
;   R3 = Chamber_PV         (PLC->Duet, tenths degC)
;   R4 = Status_Bits        (PLC->Duet, see vars.g for bit definitions)
;
; "while { iterations < 1 }" IS DELIBERATE - IT IS NOT A MISTAKE FOR "while true".
; RRF re-runs daemon.g by itself about every 10s once end-of-file is reached, so
; this file needs no loop of its own to keep polling. It DOES need a loop block
; for a different reason: M261.1's V parameter declares a local variable, and DSF
; refuses that at file top level ("Cannot add local variable because there is no
; open code block"). Tested 29/08/2026, an "if" block is NOT an acceptable
; substitute - reading plcRegs from inside one throws "unknown variable
; 'plcRegs^'", a corrupted name that appears nowhere in this file.
;
; So: a loop block that runs exactly ONCE. It gives M261.1 the block it needs and
; the reads the same shape they have always had, but the scope closes at the end
; of every invocation instead of persisting across polls. That persistence was
; the fault: a failed M261.1 left plcRegs broken in a scope that never ended, so
; the loop could never recover - later iterations either failed with "plcRegs
; already exists" or threw "unknown variable", which DSF escalates to a full
; EMERGENCY STOP (machine halted, boards 70-73 off CAN, M999 to recover). That
; fired 23/08/2026 21:41 and again 29/08/2026 14:54:38, both with the machine
; idle. exists() guards were tried and do NOT prevent it.
;
; Water pump and bay/radiator fan are thermostatic in config.g (Fan 2, Fan 3).
; No fan or pump logic belongs in this file.
; ======================================================================================

while { iterations < 1 }

    ; --- 0. Ensure globals and serial port are ready ---
    ; Guards against daemon.g starting before config.g has completed (SBC mode)
    if { !exists(global.chamberHeartbeat) }
        M98 P"/sys/vars.g"
        G4 S10

    ; --- 1. Heartbeat Counter ---
    ; Increments each invocation so the PLC can detect stale comms
    set global.chamberHeartbeat = { global.chamberHeartbeat + 1 }
    if { global.chamberHeartbeat > 32767 }
        set global.chamberHeartbeat = 0

    ; --- 2. Write to PLC ---
    ; Write all 5 registers in one transaction (partial writes may zero remainder)
    M260.1 P3 A1 F16 R0 B{global.chamberSP, global.chamberHeartbeat, global.duetControl, 0, 0}

    ; --- 3. Read from PLC ---
    M261.1 P3 A1 F3 R0 B5 V"plcRegs"

    if { var.plcRegs != null }
        set global.chamberPV = { var.plcRegs[3] }
        set global.chamberStatus = { var.plcRegs[4] }
