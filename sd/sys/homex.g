; ================================================================================
; Home X Axis - Dual-pass coarse/fine homing
; X homes to min (left) - Omron EE-SX67x on io2.in
; Drops all four AWD drivers to open loop for homing, restores closed loop after
; (per Duet 1HCL documentation). All four are switched because on CoreXY an X move
; drives both belts, so every motor participates.
; ================================================================================

; --- Drop to open loop ---
M569 P70.0 S1 D2                                                ; X1 open loop
M569 P71.0 S1 D2                                                ; X2 open loop
M569 P72.0 S1 D2                                                ; Y1 open loop
M569 P73.0 S1 D2                                                ; Y2 open loop

; --- Enable Z and wait for brakes to physically release before moving ---
; M569.7 fires the brake port at the same time as driver enable, but RRF gives
; no automatic delay in this direction (S param on M569.7 only covers the
; engage-on-disable side). Force enable and wait before the first Z move.
M17 Z                                                            ; Enable Z, releasing brakes
G4 P300                                                          ; Wait for brake solenoids to fully release

G91                                                             ; Relative positioning
G1 H2 Z5                                                        ; Lift Z for clearance
G90                                                             ; Absolute positioning

G91                                                             ; Relative positioning
var maxTravel = move.axes[0].max - move.axes[0].min + 5
G1 H1 X{-var.maxTravel} F6000                                   ; Coarse home X
G1 X5 F6000                                                     ; Back off 5mm (no H2 - CoreXY H2 is single-motor move, drives wrong way)
G1 H1 X{-var.maxTravel} F600                                    ; Fine home X
G90                                                             ; Absolute positioning

G91                                                             ; Relative positioning
G1 H2 Z-5 F6000                                                 ; Lower Z back
G90                                                             ; Absolute positioning

; --- Restore closed loop ---
M400                                                            ; Wait for all moves to complete
G4 P200                                                         ; Wait for motors to settle
M569 P70.0 S1 D4                                                ; X1 closed loop
M569 P71.0 S1 D4                                                ; X2 closed loop
M569 P72.0 S1 D4                                                ; Y1 closed loop
M569 P73.0 S1 D4                                                ; Y2 closed loop
