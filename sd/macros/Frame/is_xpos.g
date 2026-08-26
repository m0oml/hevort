; =====================================================================
; is.txt X-POSITION MODE SHAPE  -  Y sweep at X=10, X=390 and X=200
; Three-point mode shape in one continuous run under identical
; conditions. Compare against the baseline X-position test in is.txt
; (X=20 / X=200 / X=380) and the 21/08 post-fix run whose captures are
; archived in /home/trev/hevort_survey_data/accel_pre_keybak/
; (post-x10-*, post-x390-*, post1..3 = X=200).
;
; SAFETY - READ BEFORE RUNNING
;   Contains NO Z moves and must never gain any. Z is expected to be
;   faked with G92 Z250 and the bed already jogged PHYSICALLY clear.
;   The accelerometer must be mounted AT THE NOZZLE.
;   NOTE homex.g / homey.g DO contain G1 H2 Z5 / Z-5 - the head rises
;   5mm and returns during each home. Allow lead slack and headroom.
;   First approach to each new X is DELIBERATELY SLOW (F6000) so the
;   temporary sensor lead snags as a stall, not a crash. Do not speed
;   these up. The sweeps themselves run at F15000 - restored 23/08.
; =====================================================================

if !move.axes[0].homed || !move.axes[1].homed
    abort "is_xpos: home X and Y first (G92 Z250, G28 X, G28 Y)"

; --- test conditions, is.txt ---
M593 P"none"                                 ; shaper OFF
M201 X8000 Y8000                             ; 0.82g - ORIGINAL full-speed condition
M203 X15000 Y15000                           ; 250 mm/s cruise - ORIGINAL
M400

; =============== stationary control ===============
; Proves the sensor mount was not disturbed between runs. The gravity
; vector must match kb-static.csv's predecessor post-x10r-static.csv.
G4 P1000
M956 P0 S1000 A0 F"kb-static.csv"
G4 P2000

; =============== X = 10, near the left Y carriage ===============
G1 X10 Y98 F6000                             ; SLOW first approach
M400
G4 P1000

G1 X10 Y98 F15000
M400
G4 P500
M956 P0 S1000 A0 F"kb-x10-1-Y98-293-0-none.csv"
G1 Y293 F15000
M400
G4 P500

G1 X10 Y98 F15000
M400
G4 P500
M956 P0 S1000 A0 F"kb-x10-2-Y98-293-0-none.csv"
G1 Y293 F15000
M400
G4 P500

G1 X10 Y98 F15000
M400
G4 P500
M956 P0 S1000 A0 F"kb-x10-3-Y98-293-0-none.csv"
G1 Y293 F15000
M400
G4 P500

; =============== X = 390, near the right Y carriage ===============
G1 X390 Y98 F6000                            ; SLOW first approach
M400
G4 P1000

G1 X390 Y98 F15000
M400
G4 P500
M956 P0 S1000 A0 F"kb-x390-1-Y98-293-0-none.csv"
G1 Y293 F15000
M400
G4 P500

G1 X390 Y98 F15000
M400
G4 P500
M956 P0 S1000 A0 F"kb-x390-2-Y98-293-0-none.csv"
G1 Y293 F15000
M400
G4 P500

G1 X390 Y98 F15000
M400
G4 P500
M956 P0 S1000 A0 F"kb-x390-3-Y98-293-0-none.csv"
G1 Y293 F15000
M400
G4 P500

; =============== X = 200, mid-span ===============
G1 X200 Y98 F6000                            ; SLOW first approach
M400
G4 P1000

G1 X200 Y98 F15000
M400
G4 P500
M956 P0 S1000 A0 F"kb-x200-1-Y98-293-0-none.csv"
G1 Y293 F15000
M400
G4 P500

G1 X200 Y98 F15000
M400
G4 P500
M956 P0 S1000 A0 F"kb-x200-2-Y98-293-0-none.csv"
G1 Y293 F15000
M400
G4 P500

G1 X200 Y98 F15000
M400
G4 P500
M956 P0 S1000 A0 F"kb-x200-3-Y98-293-0-none.csv"
G1 Y293 F15000
M400
G4 P500

; --- park mid-span and restore ---
G1 X200 Y98 F15000
M400
M201 X35000 Y35000
M203 X30000 Y30000
M593 P"zvd" F147 S0.05
M400
echo "is_xpos complete - 9 sweeps + 1 static in sys/accelerometer/ (kb-*)"
