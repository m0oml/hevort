; ======================================================================================
; Home Y Axis - Dual-pass coarse/fine homing
; Y homes to min (front) - Omron EE-SX67x on io5.in
; ======================================================================================

G91                                              ; Relative positioning
G1 H2 Z5                                         ; Lift Z for clearance
G90                                              ; Absolute positioning

G91                                              ; Relative positioning
var maxTravel = move.axes[1].max - move.axes[1].min + 5
G1 H1 Y{-var.maxTravel} F600                     ; Coarse home Y
G1 Y5 F6000                                      ; Back off 5mm (no H2 - CoreXY H2 is single-motor move, drives wrong way)
G1 H1 Y{-var.maxTravel} F300                     ; Fine home Y
G90                                              ; Absolute positioning

G91                                              ; Relative positioning
G1 H2 Z-5 F6000                                  ; Lower Z back
G90                                              ; Absolute positioning
