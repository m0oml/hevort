; =============================================================
; trigger2.g
; Called by M581 T2 when pause button pressed (IO7, NO - make)
; Only fires during print (R1 in M581)
; =============================================================
M25                                                     ; Pause print
M118 P0 S"[PAUSE] Pause button pressed"