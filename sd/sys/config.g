; ======================================================================================
; Configuration file for Duet 3 6HC (Firmware 3.6.x)
; Machine: HevORT (CoreXY, 415x415x440mm, AWD assisted open-loop)
; Reasoning, history and evidence for these settings: project-long.txt
; ======================================================================================

; ======================= General ======================
G90                                                     ; Absolute coordinates
M83                                                     ; Relative extruder moves
M550 P"Hevort"                                          ; Set printer name
M669 K1                                                 ; CoreXY kinematics
M929 P"eventlog.txt" S1                                 ; Log warnings and errors to eventlog.txt

; ======================= Network ======================
G4 S2                                                   ; Wait 2s for CAN expansion boards

; ================ Drive Mapping & Limits ==============

; --- Onboard Drivers ---
;   Z0: front-right   Z1: rear   Z2: front-left
M569 P0.0 S0 D2                                         ; Drive 0.0: Z0 (front-right)
M569 P0.1 S0 D2                                         ; Drive 0.1: Z1 (rear)
M569 P0.2 S0 D2                                         ; Drive 0.2: Z2 (front-left)
M569 P0.5 S0 D2                                         ; Drive 0.5: Extruder (S0 = reverse; S1 fed backwards, confirmed 29/08/2026)

; --- Closed-Loop Encoders (AWD) ---
M569.1 P70.0 T3 E6:10 R30 I1000 D0.05 V500 A100000      ; X1: magnetic encoder
M569.1 P71.0 T3 E6:10 R30 I1000 D0.05 V500 A100000      ; X2: magnetic encoder
M569.1 P72.0 T3 E6:10 R30 I1000 D0.05 V500 A100000      ; Y1: magnetic encoder
M569.1 P73.0 T3 E6:10 R30 I1000 D0.05 V500 A100000      ; Y2: magnetic encoder

; --- CAN AWD Drivers (closed loop) ---
; Layout (top-down, front of printer at bottom):
;   Back-left:  73.0 Y2  |  Back-right:  70.0 X1
;   Front-left: 71.0 X2  |  Front-right: 72.0 Y1
M569 P70.0 S1 D4                                        ; Drive 70.0: X1 (back-right)
M569 P71.0 S1 D4                                        ; Drive 71.0: X2 (front-left)
M569 P72.0 S1 D4                                        ; Drive 72.0: Y1 (front-right)
M569 P73.0 S1 D4                                        ; Drive 73.0: Y2 (back-left)

; --- Axis Mapping ---
M584 X70.0:71.0 Y72.0:73.0 Z0.0:0.1:0.2 E0.5            ; X (AWD), Y (AWD), Z (triple), E
M350 X16 Y16 Z16 E16 I1                                 ; 16x microstepping with interpolation
M92 X80 Y80 Z800 E420                                   ; Steps per mm

; --- Motor Currents ---
M906 X2000 Y2000 Z1050 E1000                            ; Motor current (mA)
M917 X100 Y100                                          ; X/Y standstill current 100%
M906 I100 T1800                                         ; Idle current factor 100%, 30 min idle timeout

; --- Axis Limits ---
M208 X0:400 Y0:400 Z-10:370                             ; Axis limits (mm)

; --- Speeds and Accelerations ---
M566 X900 Y900 Z12 E120                                 ; Jerk (mm/min)
M203 X30000 Y30000 Z1000 E3600                          ; Max speeds (mm/min)
M201 X35000 Y35000 Z20 E250                             ; Accelerations (mm/s^2)

; --- Input Shaping ---
M593 P"zvd" F147                                        ; Input shaping: ZVD at 147Hz
;M955 P0 C"spi.cs3+spi.cs2" I65                          ; Accelerometer (LIS2DW, nozzle) - uncomment for input shaping

; --- Z Brake Control ---
; Brakes are power-to-release (24V releases, de-energised engages)
; OUT1 switches to GND (low-side): output HIGH = 24V to coil = released
M569.7 P0.0 C"out1" S200                                ; Z brakes on OUT1, 200ms brake-engage before driver disable

; =================== Endstops & Probes ================
M574 X1 P"io2.in" S1                                    ; X endstop (min, left) - Omron EE-SX67x
M574 Y1 P"io5.in" S1                                    ; Y endstop (min, front) - Omron EE-SX67x
M574 Z1 S2                                              ; Z endstop via probe

; Z Probe
M950 P1 C"io6.out"                                      ; GPIO 1: ALPS probe enable
M42 P1 S0                                               ; ALPS enable LOW at boot
M558 K0 P9 C"io6.in" H5:2 F600:300 T12000 A8 S0.02      ; ALPS probe on io6.in
G31 P500 X0 Y0 Z-0.030                                  ; Probe trigger height and XY offsets
M671 X424.75:201:-22.75 Y-8.75:415:-8.75 S40            ; Z0 front-right, Z1 rear, Z2 front-left; max 40mm correction

; =================== Thermal Sensors ===================
M912 P0 S-5.2                                           ; MCU temperature calibration offset
M308 S0 P"temp0" Y"pt1000" A"Hotend"                    ; Hotend PT1000
M308 S1 P"temp1" Y"thermistor" A"Coolant" T10000 B3950  ; Coolant NTC 10K B3950
M308 S2 P"temp2" Y"thermistor" A"BedMat" T100000 B3950   ; Bed mat surface 10K B3950
M308 S4 P"spi.cs0" Y"rtd-max31865" A"ElecBay"           ; Elec bay RTD Pt100 4-wire, SPI ch0
M308 S5 P"spi.cs1" Y"rtd-max31865" A"Bed"               ; Bed slab RTD Pt100 4-wire, SPI ch1
M308 S10 Y"mcu-temp" A"MCU Temp"                        ; MCU temperature sensor
M308 S11 Y"drivers" A"Driver Temp"                      ; Driver temperature

; =================== Heaters ===========================
M950 H1 C"out0" T0                                      ; Hotend heater on out0, sensor S0
M143 H1 P0 T0 S365 A0                                   ; Hotend limit 365C on sensor S0
M307 H1 R5.147 K0.348:0.572 D2.53 E1.35 S1.00 B0 V24.0  ; Hotend PID model

;M950 H0 C"out7" T5 Q1                                   ; Bed heater SSR on out7, sensor S5
M950 H0 C"out7" T2 Q1                                   ; Bed heater SSR on out7, sensor S5
M143 H0 P1 T2 S110 A0 

;M143 H0 P0 T5 S200 A0                                   ; Bed limit 200C on sensor S5
;M143 H0 P1 T2 S125 A0                                   ; Bed mat cutout 125C on sensor S2
;M307 H0 A100.0 C200.0 D5.0 B0                           ; Bed PID model

; Map bed heater
M140 P0 H0                                              ; Map H0 to bed slot 0

; ========================= Fans ========================
M950 F0 C"!out4" Q500                                   ; Fan 0: enclosure fan, 500Hz PWM, inverted
M106 P0 H10:11 T25:45                                   ; Fan 0 thermostatic on S10/S11, 25-45C

M950 F1 C"out9" Q500                                    ; Fan 1: CPAP part cooling, 500Hz PWM
M106 P1 S0 L0 X1 H-1                                    ; Fan 1 manual control, no thermostatic

M950 F2 C"out2+out5.tach" Q500                          ; Fan 2: water pump on out2, tach on out5
M106 P2 C"Pump" S0 L0 X1 H0 T40:41                              ; Fan 2 thermostatic on S0, 40-41C

M950 F3 C"!out6" Q500                                   ; Fan 3: bay/radiator fan, 500Hz PWM, inverted
M106 P3 S0 L0 X1 H4:1 T30:50                            ; Fan 3 thermostatic on S4/S1, 30-50C

; ======================== Tools =======================
M563 P0 D0 H1 F1                                        ; Tool 0: Extruder 0, Heater 1, Fan 1
M568 P0 R0 S0                                           ; Tool 0 standby/active temps to 0C
M207 P0 S0.3 R0 F3600 Z0                                ; Firmware retraction for G10/G11.
                                                        ; S0.3 starting point, direct drive
                                                        ; VZ-HextrudORT - calibrate it.
                                                        ; Z0 deliberately: M201 Z20 means a
                                                        ; hop costs ~1s in ramp alone. Use
                                                        ; the slicer retract_lift instead.
                                                        ; A filament profile can override
                                                        ; with its own M207 at print start.

; ======================= Inputs ========================
; M950 J1 C"io3.in"                                     ; Input 1: filament sensor (not fitted)

M950 J2 C"io7.in"                                       ; Input 2: pause button (NO)
M581 T2 P2 S1 R0                                        ; Trigger 2 on pause button make, during print only

M950 J3 C"!io8.in"                                      ; Input 3: stop button (NC)
M581 T3 P3 S0 R0                                        ; Trigger 3 on stop button break

; ======================= Outputs ======================
M950 P0 C"out8"                                         ; GPIO 0: PLC safety relay R1 coil
M42 P0 S0                                               ; Hold relay coil low at boot

if { sensors.gpIn[3].value = 1 }
    M42 P0 S1
    M118 P0 S"[BOOT] Stop button OK - PLC relay enabled"
else
    M118 P0 S"[BOOT] Stop button open - PLC relay held off, press pause to reset"

; ======================= Modbus =======================
M575 P3 B9600 S7                                        ; Serial 3: RS485, 9600 baud, Modbus RTU

; ===================== Finalization ===================
M98 P"vars.g"
