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
G1 X0 Y415 F6000                                        ; Park head at rear
M118 P0 S"[END] printend.g placeholder — configure before use"