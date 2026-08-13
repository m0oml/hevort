; ======================================================================================
; Home All Axes - Sequential X, Y, then Z
; AWD CoreXY with physical endstops, Z via probe at bed centre
; X and Y both home to min (left / front)
; Axes homed one at a time - on CoreXY a combined move keeps both motors driving
; after the first endstop triggers
; ======================================================================================

; --- 1. Z Clearance ---
G91                                              ; Relative positioning
G1 H2 Z5 F6000                                   ; Lift Z to clear nozzle from bed
G90                                              ; Absolute positioning

; --- 2. Home X (dual-pass coarse/fine) ---
var xTravel = move.axes[0].max - move.axes[0].min + 5
G91                                              ; Relative positioning
G1 H1 X{-var.xTravel} F600                       ; Coarse home X
G1 H2 X5 F6000                                   ; Back off 5mm
G1 H1 X{-var.xTravel} F300                       ; Fine home X
G90                                              ; Absolute positioning

; --- 3. Home Y (dual-pass coarse/fine) ---
var yTravel = move.axes[1].max - move.axes[1].min + 5
G91                                              ; Relative positioning
G1 H1 Y{-var.yTravel} F600                       ; Coarse home Y
G1 H2 Y5 F6000                                   ; Back off 5mm
G1 H1 Y{-var.yTravel} F300                       ; Fine home Y
G90                                              ; Absolute positioning

; --- 4. Home Z (probe at bed centre) ---
var xCenter = move.axes[0].min + (move.axes[0].max - move.axes[0].min) / 2 - sensors.probes[0].offsets[0]
var yCenter = move.axes[1].min + (move.axes[1].max - move.axes[1].min) / 2 - sensors.probes[0].offsets[1]
G1 X{var.xCenter} Y{var.yCenter} F6000           ; Move to bed centre
G30                                              ; Probe Z datum
