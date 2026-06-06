; plc_read.g - called from daemon.g each cycle

M261.1 P2 A1 F3 R0 B5 V"plcRegs"
if { var.plcRegs != null }
    set global.chamberPV = { var.plcRegs[3] }
    set global.chamberStatus = { var.plcRegs[4] }