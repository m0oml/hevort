; =============================================================
; chamber_abort.g
; Aborts a running chamber_heat.g wait loop
; Call from PanelDue macro list or DWC console
; =============================================================
set global.chamberAbort = 1
set global.chamberSP = 0
M118 P0 S{"[Chamber] Abort requested"}