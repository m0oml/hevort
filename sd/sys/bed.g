; ================================================================================
; Bed Compensation Macro (G32) - Triple Z-Screw Tilt Correction
; Iterative 3-point tramming using ALPS probe (K0) and M671 pivot geometry.
; Repeats G30 passes until deviation converges or 15 iterations are reached
; (Duet-documented pattern: docs.duet3d.com bed levelling using multiple
; independent Z motors).
; Pivot points (M671, in config.g) are the POS8 bearing / short MGN12 rail
; junctions, NOT the probe points below and NOT the leadscrew shaft positions.
; Probe point layout:
;   P0 - front-right (near Z0)   P1 - front-left (near Z1)   P2 - rear (near Z2)
; This does NOT run a mesh (G29) - that is a separate step once G32 converges.
; ================================================================================

; --- 1. Kinematic state validation ---
M561                                                             ; Clear any active bed transform before tramming
if !move.axes[0].homed || !move.axes[1].homed || !move.axes[2].homed
    M98 P"homeall.g"                                             ; Ensure axes are homed before probing

; --- 2. Iterative alignment loop ---
while true
    ; Point 0: front-right, near Z0
    G0 X400 Y16 F9000                                            ; Travel to front-right probe point
    M400                                                          ; Wait for move to finish
    G4 P250                                                       ; Stabilisation delay
    G30 P0 X400 Y16 Z-99999                                       ; Probe and store as point 0
    G4 P250

    ; Point 1: front-left, near Z1
    G0 X2 Y16 F9000                                              ; Travel to front-left probe point
    M400                                                          ; Wait for move to finish
    G4 P250
    G30 P1 X2 Y16 Z-99999                                         ; Probe and store as point 1
    G4 P250

    ; Point 2: rear, near Z2
    G0 X201 Y380 F9000                                           ; Travel to rear probe point
    M400                                                          ; Wait for move to finish
    G4 P250
    G30 P2 X201 Y380 Z-99999 S3                                   ; Probe point 2, calculate 3-motor correction
    M400                                                          ; Sync moves before loop evaluation
    G4 P250

    ; Convergence check: deviation threshold 0.02mm (max 15 iterations)
    if abs(move.calibration.initial.deviation) < 0.02 || iterations > 15
        break

; --- 3. Z-datum re-establishment ---
; Levelling adjustments move the bed plane; Z must be re-homed at centre
G4 P500                                                          ; Final settle time after corrections
var xCenter = move.axes[0].min + (move.axes[0].max - move.axes[0].min) / 2 - sensors.probes[0].offsets[0]
var yCenter = move.axes[1].min + (move.axes[1].max - move.axes[1].min) / 2 - sensors.probes[0].offsets[1]
G1 X{var.xCenter} Y{var.yCenter} F9000                           ; Move to bed centre
G30                                                              ; Set Z0 datum at bed centre
