; ======================================================================================
; sleep.g — called by M1 (sleep/pause from idle)
; Drops PLC safety relay to disable chamber heater
; ======================================================================================
M42 P0 S0                                               ; Drop PLC safety relay R1