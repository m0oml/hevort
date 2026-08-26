; =====================================================================
; motors_off.g  -  disable X, Y, Z and E
;
; Z brakes engage automatically on driver disable (M569.7 P0.0 C"out1"
; in config.g), so the bed stays where it is - it will not drop.
;
; NOTE this clears the homed flags on all axes. A G28 is needed before
; any positioned move afterwards.
;
; ALSO NOTE (26/08/2026): releasing the motors is not just convenience.
; Leaving them energised between G32/mesh cycles holds bed strain and
; corrupts the corner-twist metric by up to 0.1mm - see
; frame_survey_20260821.txt. M18 between every mesh run.
; =====================================================================

M400                                             ; Finish any queued moves first
M18                                              ; Disable all motors
echo "motors off - Z brakes engaged, axes now unhomed"
