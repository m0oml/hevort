; =============================================================
; trigger0.g
; Called by M581 T0 when flow switch opens (loss of flow)
; Flow switch on IO5, NC - open = no flow
; =============================================================
M42 P0 S0                                               ; Drop PLC safety relay - disables chamber heater
M104 S0                                                 ; Hotend off
M140 S0                                                 ; Bed off
M106 P2 S0                                              ; Water pump off
M25                                                     ; Pause print if running
M118 P0 S"[FLOW] Coolant flow loss detected - heaters off, print paused"