; =============================================================
; trigger1.g
; Called by M581 T1 when filament sensor triggers (IO6)
; Only fires during print (R1 in M581)
; Performs a filament change / runout pause:
;   - Lifts Z slightly to avoid heat creep on part
;   - Retracts filament clear of melt zone
;   - Parks head at X0 Y0 for filament swap access
;   - Turns off hotend to avoid ooze during wait
;   - Waits for user to resume via DWC / PanelDue
; =============================================================

M25                                                     ; Pause print (saves position for resume)
G91                                                     ; Relative moves
G1 Z5 F600                                              ; Lift Z 5mm
G90                                                     ; Back to absolute
G1 X0 Y0 F6000                                          ; Park head at front-left
G1 E-10 F300                                            ; Retract 10mm to clear melt zone
M104 S0                                                 ; Hotend off
M118 P0 S"[FILAMENT] Runout detected - load new filament and resume print"