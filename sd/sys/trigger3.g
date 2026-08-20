; =============================================================
; trigger3.g
; Called by M581 T3 when stop button breaks (IO8, NC - break)
;
; M112 is LAST - nothing after it executes, so the relay drop
; and the console message must come first.
;
; Recovery is M999. config.g holds OUT8 low on boot and only
; re-asserts it if the stop button reads closed (gpIn[3] = 1).
;
; Water pump deliberately NOT touched. Fan 2 is thermostatic
; (M106 P2 H0 T40:41) so coolant keeps moving until the hotend
; falls below 40C. Cutting it here would soak the coldside.
; =============================================================
M42 P0 S0                                               ; Drop PLC safety relay - PLC kills chamber heat
M118 P0 S"[STOP] Stop button pressed - emergency stop"
M104 S0                                                 ; Hotend off
M140 S0                                                 ; Bed off
M112                                                    ; E-stop: discards move queue, drives off, Z brakes engage
