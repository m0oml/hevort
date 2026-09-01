; ======================================================================================
; printend.g — PLACEHOLDER
; ======================================================================================
; TODO:
;   - Clear chamber setpoint if desired (set global.chamberSP = 0)
;   - Park head
;   - Turn off heaters if slicer doesn't handle it
G91                                                     ; Relative positioning
G1 Z10 F600                                             ; Lift Z 10mm
G90                                                     ; Absolute positioning
G1 X0 Y0 F9000                                          ; Park at home position.
                                                        ; WAS Y415 - OUTSIDE the M208
                                                        ; Y0:400 limit, so G1 without H
                                                        ; would have thrown every print.
                                                        ; Never fired: placeholder only.
M118 P0 S"[END] printend.g placeholder — configure before use"