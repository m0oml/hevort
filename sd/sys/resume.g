; ======================================================================================
; Resume Macro - Returns to print position and re-primes filament
; ======================================================================================

G1 R1 X0 Y0 Z5 F6000                            ; Move to 5mm above last print position
G1 R1 X0 Y0 Z0                                  ; Return to exact last print position
M83                                              ; Relative extruder moves
G1 E10 F3600                                     ; Re-prime 10mm
