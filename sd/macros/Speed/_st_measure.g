; _st_measure.g — measures endstop trigger position vs nominal
; Writes global.stX / global.stY. Called by speedtest.g.
; Uses G1 H3, which overwrites M208 — restored at the end of this file.

if !exists(global.stX)
    global stX = 0
if !exists(global.stY)
    global stY = 0

M400
G90
G1 X410 Y5 F6000                    ; approach position, 5mm off each endstop
M400

M208 X0:425 Y-10:415                ; widen limits so the H3 move can overrun
G1 H3 X425 F300                     ; creep to X max endstop, writes axes[0].max
G1 H3 Y-10 F300                     ; creep to Y min endstop, writes axes[1].min
M400

set global.stX = move.axes[0].max
set global.stY = move.axes[1].min

M208 X0:415 Y0:415                  ; restore nominal limits
G91
G1 X-5 Y5 F1200                     ; back off both endstops
G90