; =====================================================================
; is.txt POST-ALPS-FIX COMPARISON  -  Y sweep, nozzle sensor, X=200
; Conditions are fixed by sys/is.txt TEST CONDITIONS. Changing any of
; them invalidates the comparison against the 19-20/08/2026 baseline.
;
; SAFETY - READ BEFORE RUNNING
;   Contains NO Z moves and must never gain any. Z is expected to be
;   faked with G92 Z250 and the bed already jogged PHYSICALLY clear.
;   The accelerometer must be mounted AT THE NOZZLE.
; =====================================================================

if !move.axes[0].homed || !move.axes[1].homed
    abort "is_recheck: home X and Y first (G92 Z250, G28 X, G28 Y)"

; --- test conditions, is.txt ---
M593 P"none"                                 ; shaper OFF
M201 X8000 Y8000                             ; 0.82g - avoids +-2g clipping
M203 X15000 Y15000                           ; 250 mm/s cruise
M400

; --- run 1 ---
G1 X200 Y98 F15000                           ; mid-span, start of sweep
M400
G4 P500
M956 P0 S1000 A0 F"post1-Y98-293-0-none.csv"
G1 Y293 F15000
M400
G4 P500

; --- run 2 ---
G1 X200 Y98 F15000
M400
G4 P500
M956 P0 S1000 A0 F"post2-Y98-293-0-none.csv"
G1 Y293 F15000
M400
G4 P500

; --- run 3 ---
G1 X200 Y98 F15000
M400
G4 P500
M956 P0 S1000 A0 F"post3-Y98-293-0-none.csv"
G1 Y293 F15000
M400
G4 P500

; --- restore, is.txt "Restore after" line ---
M201 X35000 Y35000
M203 X30000 Y30000
M593 P"zvd" F147
M400
echo "is_recheck complete - 3 captures in sys/accelerometer/"
