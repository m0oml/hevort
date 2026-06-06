; ======================================================================================
; stop.g — called by M0 (end of print / stop)
; Normal end of print — does NOT drop PLC safety relay
; Chamber continues heating if SP is set (e.g. post-print soak)
; Chamber setpoint management handled by printend.g
; ======================================================================================
; Intentionally does not drop OUT8 — only genuine stop/estop should do that