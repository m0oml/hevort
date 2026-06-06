; ======================================================================================
; Home X Axis - Dual-pass coarse/fine homing
; ======================================================================================

G91                                              ; Relative positioning
G1 H2 Z5                                         ; Lift Z for clearance
G90                                              ; Absolute positioning

G91                                              ; Relative positioning
var maxTravel = move.axes[0].max - move.axes[0].min + 5
G1 H1 X{-var.maxTravel} F600                     ; Coarse home X
G1 X5 F6000                                     ; Back off 5mm
G1 H1 X{-var.maxTravel} F300                     ; Fine home X
G90                                              ; Absolute positioning

G91                                              ; Relative positioning
G1 H2 Z-5 F6000                                 ; Lower Z back
G90                                              ; Absolute positioning
