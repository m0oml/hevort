; =====================================================================
; belt_check.g  -  belt tension gauge using the closed-loop motors
;
; Runs ONE standard move under fixed conditions and records what the
; motors had to do. Peak PID effort tracks belt tension: a slack belt
; needs more control authority for the same move. No plucking, no app.
;
; ALWAYS RUN belt_settle FIRST so tension is distributed - a reading
; taken straight after adjustment will drift.
;
; Standard conditions - DO NOT CHANGE, the calibration depends on them:
;   400 mm/s, 35000 mm/s^2, Y98 -> Y293 at X200, shaper OFF
;
; Writes sys/closed-loop/bc-72_0.csv and bc-70_0.csv, one per belt pair:
;   70.0/71.0 = X pair    72.0/73.0 = Y pair
;
; *** CALIBRATION VOID AND REBUILDING - 26/08/2026 ***
; The first calibration (188->78N, 226->55N, 239->41N) was taken while the
; GANTRY WAS RACKED and was reading rack, not tension. Squaring the gantry
; dropped the same move from 227/240 to 140/148 with belts UNCHANGED at
; 111 Hz - about 90 units of PID, over a third of each motor's authority,
; was going into dragging a skewed gantry. Those points are discarded.
;
; VALID POINTS (square gantry only):
;     133 (X pair) / 134 (Y pair)  ->  38.8 N  (MEASURED: plucked 85/88 Hz on
;                                            a 260mm span, square gantry, RC2 2.8)
;   An earlier "140/148 -> ~60 N" point was a GUESS and is discarded - if it had
;   really been 60 N this move would have read LOWER than it does at 38 N.
; ATTRIBUTION IS CLEAN: before squaring, 64 N (plucked 111 Hz) gave 227/240.
; After squaring, slightly LOWER tension (~60 N) gives 140/148. Tension went
; DOWN and effort fell 38%, so the whole improvement is the rack.
;
; HIGHER PID = SLACKER BELT, but this tool measures MOTOR EFFORT, so it reads
; anything that loads the motors - rack, binding, a dragging carriage - as
; slack belt. It is a tension tracker on a KNOWN-SQUARE machine, never a
; diagnosis on its own. If a reading jumps without the belts being touched,
; suspect geometry before tension.
; Add a point each time tension is set by pluck AND this is run.
;
; Contains NO Z moves, safe with an accelerometer fitted.
; =====================================================================

if !move.axes[0].homed || !move.axes[1].homed
    abort "belt_check: home X and Y first"

M593 P"none"                                     ; Shaper off - it would mask the demand
M203 X30000 Y30000
M201 X35000 Y35000
M400

G90
G1 X200 Y98 F9000                                ; Approach at a modest speed
M400
G4 P1200                                         ; Let it settle before capturing

M569.5 P72.0 S3000 R4000 A1 D24 F"bc-72_0.csv"   ; Y pair
G1 Y293 F24000
M400
G4 P1500                                         ; Must fully finish writing before the next capture

G1 X200 Y98 F9000
M400
G4 P1200

M569.5 P70.0 S3000 R4000 A1 D24 F"bc-70_0.csv"   ; X pair
G1 Y293 F24000
M400
G4 P1500

G1 X200 Y195 F9000
M400
M593 P"zvd" F147 S0.05                           ; Restore the shaper
M400
echo "belt_check complete - captures in sys/closed-loop/bc-*.csv"
