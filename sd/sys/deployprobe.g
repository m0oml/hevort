; ================================================================================
; deployprobe.g - ALPS strain-gauge probe enable
; RRF runs this before every probing move. M558 P9 retracts and redeploys BETWEEN
; probe points, so on a 49-point mesh this executes 49 times - keep it cheap.
;
; The enable is CYCLED, not just asserted. The typical hot-chamber failure is
; "Z probe already triggered at start of probing move": the resting value is at
; or above the G31 threshold before the nozzle has moved anywhere. Dropping the
; enable and re-asserting forces the gauge to re-zero. On a healthy point this
; costs one object-model read and nothing else - the 1s retry only runs when the
; baseline is actually bad, so it does not lengthen a normal mesh.
;
; Compared against sensors.probes[0].threshold, not a hardcoded 500, so it
; follows G31 P automatically.
; ================================================================================

while true
    M42 P1 S1                                           ; Assert ALPS enable
    G4 P300                                             ; Settle

    if { sensors.probes[0].value[0] < sensors.probes[0].threshold }
        break                                           ; Clean baseline - go and probe

    if { iterations >= 2 }
        abort {"deployprobe.g: ALPS still reads " ^ sensors.probes[0].value[0] ^ " against threshold " ^ sensors.probes[0].threshold ^ " after 3 enable cycles - gauge not returning to zero"}

    M118 P0 S{"[PROBE] already triggered at deploy, value " ^ sensors.probes[0].value[0] ^ " - re-taring"}
    M42 P1 S0                                           ; Drop enable to force a re-tare
    G4 P1000                                            ; Let the gauge relax before retrying
