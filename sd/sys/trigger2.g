; trigger2.g
; Pause button on IO7
; If chamber heatup is in progress — abort it
; If printing — pause print

if { global.chamberSP > 0 && state.status != "processing" && state.status != "paused" }
    set global.chamberAbort = 1
    set global.chamberSP = 0
    M118 P0 S{"[Chamber] Heatup aborted via pause button"}
else
    M25
    M118 P0 S{"[PAUSE] Pause button pressed"}