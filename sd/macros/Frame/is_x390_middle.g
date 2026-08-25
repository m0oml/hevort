; =====================================================================
; is.txt X=390 MIDDLE LOCALISATION - 180mm/s, matches is_x390_frontrear.g
; Tests the middle of Y travel (Y155-235, 80mm span, same length as the
; front/rear segments) to see whether the remaining general right-side
; effect (seen in the standard Y98-293 sweep, unaffected by the rear-
; right shim) is itself localised somewhere in the middle, or spread.
; Directly comparable to x390-front-*.csv / x390-rear-*.csv at the same
; 180mm/s conditions (23/08/2026, post rear-right shim).
;
; SAFETY - READ BEFORE RUNNING
;   Contains NO Z moves. Z must be faked with G92 Z250, bed jogged
;   PHYSICALLY clear. Accelerometer mounted AT THE NOZZLE.
;   First approach to X=390 is SLOW (F6000) for the sensor lead.
; =====================================================================

if !move.axes[0].homed || !move.axes[1].homed
    abort "is_x390_middle: home X and Y first (G92 Z250, G28 X, G28 Y)"

M593 P"none"                                 ; shaper OFF
M201 X4000 Y4000                             ; 0.41g - 250mm/s cruise, reduced accel to avoid clip, 23/08
M203 X15000 Y15000                           ; 250 mm/s cruise
M400

G1 X390 Y155 F6000                           ; SLOW first approach
M400
G4 P1000

; =============== MIDDLE segment, Y155 -> Y235 ===============
G1 X390 Y155 F15000
M400
G4 P500
M956 P0 S1000 A0 F"x390-middle-1.csv"
G1 Y235 F15000
M400
G4 P500

G1 X390 Y155 F15000
M400
G4 P500
M956 P0 S1000 A0 F"x390-middle-2.csv"
G1 Y235 F15000
M400
G4 P500

G1 X390 Y155 F15000
M400
G4 P500
M956 P0 S1000 A0 F"x390-middle-3.csv"
G1 Y235 F15000
M400
G4 P500

; --- back to mid-span and restore ---
G1 X200 Y195 F15000
M400
M201 X35000 Y35000
M203 X30000 Y30000
M593 P"zvd" F127 S0.05
M400
echo "is_x390_middle complete - 3 captures in sys/accelerometer/ (x390-middle-*)"
