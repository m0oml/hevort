; trigger2.g
; Pause button on IO7
; If OUT8 low and stop button closed — reset PLC relay first
; If chamber heatup is in progress — abort it
; If printing — pause print

; PLC relay reset — only if OUT8 is low and stop button is confirmed closed
if { state.gpOut[0].pwm = 0.0 && sensors.gpIn[3].value = 1 }
    M42 P0 S1
    M118 P0 S"[RESET] Stop button closed - PLC relay re-enabled"

if { global.chamberSP > 0 && state.status != "processing" && state.status != "paused" }
    set global.chamberAbort = 1
    set global.chamberSP = 0
    M118 P0 S"[Chamber] Heatup aborted via pause button"
else
    M25
    M118 P0 S"[PAUSE] Pause button pressed"