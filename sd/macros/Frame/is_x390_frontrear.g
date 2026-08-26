; =====================================================================
; is.txt X=390 FRONT/REAR LOCALISATION - original full speed/accel
; Splits the Y98->293 sweep into two short, separate captures near the
; front (Y30-110) and rear (Y280-360) of Y travel, at X=390 only, to
; localise the amplitude-dependent right-side effect found 23/08/2026
; (present at 250mm/s, absent at 180mm/s, only ever seen at X=390).
;
; NOTE: each short move (~80mm) finishes BEFORE the 1000-sample capture
; window ends, so captures include some post-move ring-down, not pure
; sustained cruise like the full-length sweeps. Not directly comparable
; in absolute amplitude to earlier full-sweep numbers - front vs rear
; comparison WITHIN this test is what matters.
;
; SAFETY - READ BEFORE RUNNING
;   Contains NO Z moves. Z must be faked with G92 Z250, bed jogged
;   PHYSICALLY clear. Accelerometer mounted AT THE NOZZLE.
;   First approach to X=390 is SLOW (F6000) for the sensor lead.
; =====================================================================

if !move.axes[0].homed || !move.axes[1].homed
    abort "is_x390_frontrear: home X and Y first (G92 Z250, G28 X, G28 Y)"

M593 P"none"                                 ; shaper OFF
M201 X4000 Y4000                             ; 0.41g - 250mm/s cruise, reduced accel to avoid clip, 23/08
M203 X15000 Y15000                           ; 250 mm/s cruise - 23/08 rerun at full speed
M400

G1 X390 Y30 F6000                            ; SLOW first approach
M400
G4 P1000

; =============== FRONT segment, Y30 -> Y110 ===============
G1 X390 Y30 F15000
M400
G4 P500
M956 P0 S1000 A0 F"x390-front-1.csv"
G1 Y110 F15000
M400
G4 P500

G1 X390 Y30 F15000
M400
G4 P500
M956 P0 S1000 A0 F"x390-front-2.csv"
G1 Y110 F15000
M400
G4 P500

G1 X390 Y30 F15000
M400
G4 P500
M956 P0 S1000 A0 F"x390-front-3.csv"
G1 Y110 F15000
M400
G4 P500

; =============== REAR segment, Y280 -> Y360 ===============
G1 X390 Y280 F15000
M400
G4 P500
M956 P0 S1000 A0 F"x390-rear-1.csv"
G1 Y360 F15000
M400
G4 P500

G1 X390 Y280 F15000
M400
G4 P500
M956 P0 S1000 A0 F"x390-rear-2.csv"
G1 Y360 F15000
M400
G4 P500

G1 X390 Y280 F15000
M400
G4 P500
M956 P0 S1000 A0 F"x390-rear-3.csv"
G1 Y360 F15000
M400
G4 P500

; --- back to mid-span and restore ---
G1 X200 Y195 F15000
M400
M201 X35000 Y35000
M203 X30000 Y30000
M593 P"zvd" F147 S0.05
M400
echo "is_x390_frontrear complete - 6 captures in sys/accelerometer/ (x390-front/rear-*)"
