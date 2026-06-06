; ======================================================================================
; Home Y Axis - Dual-pass coarse/fine homing
; ======================================================================================

G91                                              ; Relative positioning
G1 H2 Z5                                         ; Lift Z for clearance
G90                                              ; Absolute positioning

G91                                              ; Relative positioning
var maxTravel = move.axes[1].max - move.axes[1].min + 5
G1 H1 Y{-var.maxTravel} F600                     ; Coarse home Y
G1 Y5 F6000                                     ; Back off 5mm
G1 H1 Y{-var.maxTravel} F300                     ; Fine home Y
G90                                              ; Absolute positioning

G91                                              ; Relative positioning
G1 H2 Z-5 F6000                                 ; Lower Z back
G90                                              ; Absolute positioning
