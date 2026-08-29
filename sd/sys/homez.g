; ================================================================================
; Home Z Axis - Probe at bed centre
; No AWD mode change needed - Z runs on onboard drivers, and the XY move to centre
; is a normal positioning move in whatever mode XY is already in
; ================================================================================

; --- Enable Z and wait for brakes to physically release before moving ---
; M569.7 fires the brake port at the same time as driver enable, but RRF gives
; no automatic delay in this direction (S param on M569.7 only covers the
; engage-on-disable side). Force enable and wait before the first Z move.
M17 Z                                                            ; Enable Z, releasing brakes
G4 P800                                                          ; Wait for brake solenoids to fully release

G91                                                             ; Relative positioning
G1 H2 Z5                                                        ; Lift Z for clearance
G90                                                             ; Absolute positioning

var xCenter = move.axes[0].min + (move.axes[0].max - move.axes[0].min) / 2 - sensors.probes[0].offsets[0]
var yCenter = move.axes[1].min + (move.axes[1].max - move.axes[1].min) / 2 - sensors.probes[0].offsets[1]
G1 X{var.xCenter} Y{var.yCenter} F6000                          ; Move to bed centre
G30                                                             ; Probe Z datum
if result != 0
    abort "Z homing failed: probe did not trigger"