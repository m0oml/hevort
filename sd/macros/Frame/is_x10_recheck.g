; =====================================================================
; is.txt X=10 RE-RUN WITH THE SENSOR LEAD RE-ROUTED
; Tests whether the left-end broadband/rms elevation found 21/08/2026
; (X=10 rms 0.366 vs X=390 rms 0.228) is a machine property or an
; artefact of the temporary accelerometer lead.
;
; Conditions IDENTICAL to macros/Frame/is_xpos.g - the only thing that may
; differ between the two data sets is the lead routing. Change nothing
; else or the comparison is void.
;
; SAFETY: no Z moves. Z faked at 250, bed physically clear, sensor at
;         the nozzle. First approach to X=10 is slow (F6000).
; =====================================================================

if !move.axes[0].homed || !move.axes[1].homed
    abort "is_x10_recheck: home X and Y first (G92 Z250, G28 X, G28 Y)"

M593 P"none"                                 ; shaper OFF
M201 X8000 Y8000
M203 X15000 Y15000
M400

G1 X10 Y98 F6000                             ; SLOW first approach
M400
G4 P1000

; --- stationary control: proves the reroute did not disturb the mount ---
M956 P0 S1000 A0 F"post-x10r-static.csv"
G4 P1500

G1 X10 Y98 F15000
M400
G4 P500
M956 P0 S1000 A0 F"post-x10r-1-Y98-293-0-none.csv"
G1 Y293 F15000
M400
G4 P500

G1 X10 Y98 F15000
M400
G4 P500
M956 P0 S1000 A0 F"post-x10r-2-Y98-293-0-none.csv"
G1 Y293 F15000
M400
G4 P500

G1 X10 Y98 F15000
M400
G4 P500
M956 P0 S1000 A0 F"post-x10r-3-Y98-293-0-none.csv"
G1 Y293 F15000
M400
G4 P500

G1 X200 Y98 F15000
M400
M201 X35000 Y35000
M203 X30000 Y30000
M593 P"zvd" F127 S0.05
M400
echo "is_x10_recheck complete - static + 3 captures in sys/accelerometer/"
