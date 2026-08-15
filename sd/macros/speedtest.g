; speedtest.g — HevORT speed / acceleration stress test
; Homes, measures endstop reference, runs a stress pattern, re-measures.
; Non-zero drift = lost steps / belt slip / gantry racking.
;
; Usage:  M98 P"0:/macros/speedtest.g" S300 A10000 L10
;   S = test speed  mm/s   (default 200)
;   A = test accel  mm/s^2 (default 5000)
;   L = loop count         (default 5)
;
; PREREQUISITES — do not run before all of these are true:
;   - Z brake release timing verified on replacement 42HSB47A41505 set
;   - CAN nodes 70-73 commissioned, M569.1 tuned, no position warnings idle
;   - Gantry squared, belts tensioned, bed clear of obstructions
;   - Nozzle parked clear of the bed (Z raised) — this macro does NOT move Z

; ---------- parameters ----------
var spd   = 200
var acc   = 5000
var loops = 5
if exists(param.S)
    set var.spd = param.S
if exists(param.A)
    set var.acc = param.A
if exists(param.L)
    set var.loops = param.L

; ---------- restore values (MUST match config.g) ----------
var rSpeedXY = 6000                 ; M203 mm/min
var rAccelXY = 500                  ; M201 mm/s^2
var rJerkXY  = 900                  ; M566 mm/min

; ---------- envelope ----------
var lo = 10                         ; margin from axis minima
var hi = 300                        ; margin from axis maxima
var bl = 150                        ; small-box lower bound
var bh = 265                        ; small-box upper bound

; ---------- pre-flight ----------
if !move.axes[0].homed || !move.axes[1].homed
    G28 X Y

echo "SPEEDTEST: " ^ var.spd ^ " mm/s, " ^ var.acc ^ " mm/s^2, " ^ var.loops ^ " loops"

; ---------- baseline (also gives endstop repeatability noise floor) ----------
G28 X Y
M98 P"0:/macros/_st_measure.g"
var baseX = global.stX
var baseY = global.stY
echo "Baseline: X " ^ var.baseX ^ "  Y " ^ var.baseY

; ---------- apply test limits ----------
M201 X{var.acc} Y{var.acc}
M203 X{var.spd * 60} Y{var.spd * 60}
M566 X{var.rJerkXY} Y{var.rJerkXY}

; ---------- stress pattern ----------
while iterations < var.loops
    ; full-envelope diagonals — peak velocity, both motors loaded
    G1 X{var.lo} Y{var.lo} F{var.spd * 60}
    G1 X{var.hi} Y{var.hi} F{var.spd * 60}
    G1 X{var.lo} Y{var.hi} F{var.spd * 60}
    G1 X{var.hi} Y{var.lo} F{var.spd * 60}

    ; full-envelope box — single-axis moves, worst case for one motor pair
    G1 X{var.lo} Y{var.lo} F{var.spd * 60}
    G1 X{var.lo} Y{var.hi} F{var.spd * 60}
    G1 X{var.hi} Y{var.hi} F{var.spd * 60}
    G1 X{var.hi} Y{var.lo} F{var.spd * 60}
    G1 X{var.lo} Y{var.lo} F{var.spd * 60}

    ; short high-frequency moves — accel-dominated, never reaches cruise
    while iterations < 20
        G1 X{var.bl} Y{var.bl} F{var.spd * 60}
        G1 X{var.bh} Y{var.bh} F{var.spd * 60}
        G1 X{var.bl} Y{var.bh} F{var.spd * 60}
        G1 X{var.bh} Y{var.bl} F{var.spd * 60}

M400

; ---------- re-measure ----------
M201 X{var.rAccelXY} Y{var.rAccelXY}
M203 X{var.rSpeedXY} Y{var.rSpeedXY}
M98 P"0:/macros/_st_measure.g"

var driftX = global.stX - var.baseX
var driftY = global.stY - var.baseY

echo "Post-test: X " ^ global.stX ^ "  Y " ^ global.stY
echo "DRIFT: X " ^ var.driftX ^ " mm   Y " ^ var.driftY ^ " mm"

if var.driftX > 0.15 || var.driftX < -0.15 || var.driftY > 0.15 || var.driftY < -0.15
    echo "*** FAIL — lost motion detected. Reduce speed/accel and retest. ***"
else
    echo "PASS at " ^ var.spd ^ " mm/s / " ^ var.acc ^ " mm/s^2"

; ---------- restore ----------
M566 X{var.rJerkXY} Y{var.rJerkXY}
M208 X0:415 Y0:415
G28 X Y