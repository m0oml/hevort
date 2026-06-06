; ======================================================================================
; Home Z Axis - Probe at bed centre
; ======================================================================================

G91                                              ; Relative positioning
G1 H2 Z5                                         ; Lift Z for clearance
G90                                              ; Absolute positioning

var xCenter = move.axes[0].min + (move.axes[0].max - move.axes[0].min) / 2 - sensors.probes[0].offsets[0]
var yCenter = move.axes[1].min + (move.axes[1].max - move.axes[1].min) / 2 - sensors.probes[0].offsets[1]
G1 X{var.xCenter} Y{var.yCenter} F6000          ; Move to bed centre
G30                                              ; Probe Z datum
