; PLC Status Report
echo "=== HevORT Chamber PLC Status ==="
echo ""
echo { "Chamber SP:     " ^ (global.chamberSP / 10.0) ^ " degC" }
echo { "Chamber PV:     " ^ (global.chamberPV / 10.0) ^ " degC" }
echo { "Heartbeat:      " ^ global.chamberHeartbeat }
echo ""
echo "=== PLC Status Bits ==="
var s = { global.chamberStatus }
echo { "Chamber sensor:  " ^ (mod(floor(var.s / 1), 2) == 1 ? "FAULT" : "OK") }
echo { "Top sensor:      " ^ (mod(floor(var.s / 2), 2) == 1 ? "FAULT" : "OK") }
echo { "Bottom sensor:   " ^ (mod(floor(var.s / 4), 2) == 1 ? "FAULT" : "OK") }
echo { "Heater:          " ^ (mod(floor(var.s / 8), 2) == 1 ? "FAULT" : "OK") }
echo { "PLC heartbeat:   " ^ (mod(floor(var.s / 16), 2) == 1 ? "HIGH" : "LOW") }
echo { "PLC running:     " ^ (mod(floor(var.s / 32), 2) == 1 ? "YES" : "NO") }
echo { "Duet comms:      " ^ (mod(floor(var.s / 64), 2) == 1 ? "OK" : "FAULT") }
echo { "Duet comms fault:" ^ (mod(floor(var.s / 128), 2) == 1 ? "YES" : "NO") }
echo ""
echo "=== Duet Control Bits ==="
var c = { global.duetControl }
echo { "Printer active:  " ^ (mod(floor(var.c / 1), 2) == 1 ? "YES" : "NO") }
echo ""
echo "=== Job Status ==="
echo { "Duet status:     " ^ state.status }