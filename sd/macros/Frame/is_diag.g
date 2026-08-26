; =====================================================================
; is.txt DIAGONAL BELT ISOLATION  -  X+Y diagonal vs X-Y diagonal
; Reproduces the resonance-lab "belt A / belt B" excitation with plain
; G-code, at the SAME clean cruise-capture conditions as is_xpos.g,
; instead of the plugin's clipping/mistimed sweep.
;
; On this CoreXY, a pure X or Y move drives BOTH belts together (see
; homex.g). Only a 45-degree diagonal move isolates one belt pair:
;   dX = +dY   ->  drives ONLY the "X" pair (70.0 + 71.0)
;   dX = -dY   ->  drives ONLY the "Y" pair (72.0 + 73.0)
; This is the actual belt A / belt B split the plugin claims to test.
;
; SAFETY - READ BEFORE RUNNING
;   Contains NO Z moves. Z must be faked with G92 Z250, bed jogged
;   PHYSICALLY clear. Accelerometer mounted AT THE NOZZLE.
;   First move to each new corner is SLOW (F6000) for the sensor lead.
; =====================================================================

if !move.axes[0].homed || !move.axes[1].homed
    abort "is_diag: home X and Y first (G92 Z250, G28 X, G28 Y)"

M593 P"none"                                 ; shaper OFF
M201 X8000 Y8000                             ; 0.82g - ORIGINAL full-speed condition
M203 X15000 Y15000                           ; 250 mm/s cruise - ORIGINAL
M400

; =============== DIAGONAL A  (dX=+dY, isolates X pair 70/71) ===============
G1 X133 Y128 F6000                           ; SLOW first approach
M400
G4 P1000

G1 X133 Y128 F15000
M400
G4 P500
M956 P0 S1000 A0 F"diagA-1.csv"
G1 X267 Y262 F15000
M400
G4 P500

G1 X133 Y128 F15000
M400
G4 P500
M956 P0 S1000 A0 F"diagA-2.csv"
G1 X267 Y262 F15000
M400
G4 P500

G1 X133 Y128 F15000
M400
G4 P500
M956 P0 S1000 A0 F"diagA-3.csv"
G1 X267 Y262 F15000
M400
G4 P500

; =============== DIAGONAL B  (dX=-dY, isolates Y pair 72/73) ===============
G1 X133 Y262 F6000                           ; SLOW first approach
M400
G4 P1000

G1 X133 Y262 F15000
M400
G4 P500
M956 P0 S1000 A0 F"diagB-1.csv"
G1 X267 Y128 F15000
M400
G4 P500

G1 X133 Y262 F15000
M400
G4 P500
M956 P0 S1000 A0 F"diagB-2.csv"
G1 X267 Y128 F15000
M400
G4 P500

G1 X133 Y262 F15000
M400
G4 P500
M956 P0 S1000 A0 F"diagB-3.csv"
G1 X267 Y128 F15000
M400
G4 P500

; --- back to mid-span and restore ---
G1 X200 Y195 F15000
M400
M201 X35000 Y35000
M203 X30000 Y30000
M593 P"zvd" F147 S0.05
M400
echo "is_diag complete - 6 captures in sys/accelerometer/ (diagA/diagB-*)"
