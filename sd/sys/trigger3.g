; =============================================================
; trigger3.g
; Called by M581 T3 when stop button breaks (IO8, NC - break)
; =============================================================
M42 P0 S0                                               ; Drop PLC safety relay
M104 S0                                                 ; Hotend off
M140 S0                                                 ; Bed off
M106 P2 S0                                              ; Water pump off
M0                                                      ; Stop print, motors off
M118 P0 S"[STOP] Stop button pressed - all heaters off"