; =====================================================================
; belt_settle.g  -  work the belts around their loops before gauging
;
; Runs a 250mm box in both directions to redistribute any tension
; difference around the belt path, then parks at X200 Y0 with the
; MOTORS STILL HELD so tension can be gauged in place without the
; gantry being free to move.
;
; DOES NOT DISABLE MOTORS. Do not add M18 - the whole point is that
; the gantry stays locked while you put the meter on the belt.
;
; Contains NO Z moves, so it is safe with the accelerometer fitted.
; Created 25/08/2026 for the belt-tension input-shaping series.
; =====================================================================

if !move.axes[0].homed || !move.axes[1].homed
    abort "belt_settle: home X and Y first"

; 250mm box, centred on the bed in X, comfortably inside Y travel
var x0 = 75
var x1 = 325
var y0 = 70
var y1 = 320
var fast = 18000                                 ; 300 mm/s

G90                                              ; Absolute positioning
G1 X{var.x0} Y{var.y0} F9000                     ; Move to the box corner at a modest speed first
M400

; --- two laps clockwise ---
while iterations < 2
    G1 X{var.x1} Y{var.y0} F{var.fast}
    G1 X{var.x1} Y{var.y1} F{var.fast}
    G1 X{var.x0} Y{var.y1} F{var.fast}
    G1 X{var.x0} Y{var.y0} F{var.fast}
M400

; --- two laps anticlockwise, so each belt is worked in both directions ---
while iterations < 2
    G1 X{var.x0} Y{var.y1} F{var.fast}
    G1 X{var.x1} Y{var.y1} F{var.fast}
    G1 X{var.x1} Y{var.y0} F{var.fast}
    G1 X{var.x0} Y{var.y0} F{var.fast}
M400

; --- park for gauging ---
G1 X200 Y0 F{var.fast}
M400
G4 P1000                                         ; Let everything come to rest before measuring
echo "belt_settle complete - parked X200 Y0, motors HELD, ready to gauge"
