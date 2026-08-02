; ======================================================================================
; printstart.g — PLACEHOLDER
; ======================================================================================
; TODO:
;   - Accept chamber setpoint from slicer (S parameter or slicer variable)
;   - Call M98 P"/macros/chamber_heat.g" S{target} to preheat if needed
;   - Home if not homed
;   - Load bed mesh
M98 P"0:/sys/homeall.g"                                 ; Home all axes
G29 S1                                                  ; Load saved bed mesh
M118 P0 S"[START] printstart.g placeholder — configure before use"