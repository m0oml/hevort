; ======================================================================================
; Configuration file for Duet 3 6HC (Firmware 3.6.x)
; Machine: HevORT (CoreXY, 415x415x440mm, AWD assisted open-loop)
; ======================================================================================

; ======================= General ======================
G90                                                     ; Absolute coordinates
M83                                                     ; Relative extruder moves
M550 P"Hevort"                                          ; Set printer name
M669 K1                                                 ; CoreXY kinematics

; ======================= Network ======================
G4 S2                                                   ; Wait 2s for CAN expansion boards

; ================ Drive Mapping & Limits ==============

; --- Onboard Drivers ---
; Z axis: conventional steppers on onboard drivers
M569 P0.0 S1 D2                                         ; Drive 0.0: Z0
M569 P0.1 S1 D2                                         ; Drive 0.1: Z1
M569 P0.2 S1 D2                                         ; Drive 0.2: Z2
; Extruder: onboard driver 0.5 (closest to edge)
M569 P0.5 S1 D2                                         ; Drive 0.5: Extruder

; --- CAN AWD Drivers (assisted open-loop) ---
; Layout (top-down, front of printer at bottom):
;   Back-left:  73.0 Y2  |  Back-right:  70.0 X1
;   Front-left: 71.0 X2  |  Front-right: 72.0 Y1
M569 P70.0 S1 D3                                        ; Drive 70.0: X1 (back-right)
M569 P71.0 S1 D3                                        ; Drive 71.0: X2 (front-left)
M569 P72.0 S1 D3                                        ; Drive 72.0: Y1 (front-right)
M569 P73.0 S1 D3                                        ; Drive 73.0: Y2 (back-left)

; --- Closed-Loop Encoders (AWD) ---
M569.1 P70.0 T3                                         ; X1: magnetic encoder
M569.1 P71.0 T3                                         ; X2: magnetic encoder
M569.1 P72.0 T3                                         ; Y1: magnetic encoder
M569.1 P73.0 T3                                         ; Y2: magnetic encoder

; --- Axis Mapping ---
M584 X70.0:71.0 Y72.0:73.0 Z0.0:0.1:0.2 E0.5          ; X (AWD), Y (AWD), Z (triple), E
M350 X16 Y16 Z16 E16 I1                                 ; 16x microstepping with interpolation
M92 X80 Y80 Z800 E420                                   ; Steps per mm

; --- Motor Currents ---
M906 X2600 Y2600 Z1400 E1000                            ; Motor current (mA)
M917 X0 Y0                                              ; AWD holding current zero (closed-loop corrects drift)
M906 I30                                                ; Idle current factor 30% (Z and E)
M84 S30                                                 ; Motor idle timeout (30s)

; --- Axis Limits (PLACEHOLDER - update after homing verified) ---
M208 X0:415 Y0:415 Z0:415                               ; Axis limits

; --- Speeds and Accelerations (conservative - tune after input shaper) ---
M566 X900 Y900 Z12 E120                                 ; Jerk (mm/min)
M203 X6000 Y6000 Z180 E3600                             ; Max speeds (mm/min)
M201 X500 Y500 Z20 E250                                 ; Accelerations (mm/s^2) - placeholder

; --- Z Brake Control ---
; Brakes are power-to-release (24V releases, de-energised engages)
; OUT1 switches to GND (low-side): output HIGH = 24V to coil = released
; Brakes auto-engage on motor disable via M569.7
; S200 = 200ms delay before driver disables after brake engages (placeholder - tune on hardware)
M569.7 P0.0 C"out1" S200                                ; Z brakes on OUT1 (commoned across Z0/Z1/Z2 — single brake config covers all three via shared output)

; =================== Endstops & Probes ================
; X homes to max (right), Y homes to min (front)
M574 X2 P"io2.in" S1                                    ; X endstop (max, right) - Omron EE-SX67x
M574 Y1 P"io5.in" S1                                    ; Y endstop (min, front) - Omron EE-SX67x
M574 Z1 S2                                              ; Z endstop via probe

; Z Probe
M558 K0 P5 C"io6.in" H5 F120 T6000                      ; Digital probe on io6
G31 P500 X0 Y0 Z0.7                                     ; Probe trigger value, offset, trigger height (PLACEHOLDER)

; =================== Thermal Sensors ==================
M912 P0 S-5.2                                           ; Set MCU calibration offset BEFORE defining the sensor
M308 S0 P"temp0" Y"pt1000" A"Hotend"                    ; Hotend PT1000
M308 S1 P"temp1" Y"thermistor" A"Bed" T10000 B3950     ; Bed interior thermistor 10K B3950 - PID source
M308 S2 P"temp2" Y"thermistor" A"BedMat" T10000 B3950  ; Bed heater mat surface 10K B3950 - safety limit only
M308 S3 P"temp3" Y"thermistor" A"Coolant" T10000 B3950  ; Coolant NTC 10K B3950 (Alphacool Eiszapfen)
M308 S10 Y"mcu-temp" A"MCU Temp"                        ; MCU temperature sensor
M308 S11 Y"drivers" A"Driver Temp"                      ; Driver temperature (0/100/130C states


; =================== Heaters ==========================
; Hotend Heater (H1) on OUT0 (highest rated output, 15A)
M950 H1 C"out0" T0                                      ; Hotend heater on out0, sensor S0
M143 H1 P0 T0 S350 A0                                   ; Hotend safety limit 350C (no secondary sensor)
M307 H1 R2.43 D5.5 E1.35 K0.56 B0                       ; Hotend PID model (PLACEHOLDER - autotune required)

; Bed Heater (H0) SSR control on OUT7
; PID controlled from bed interior sensor S1 (temp1)
; Independent over-temp cutout on mat surface sensor S2 (temp2), limit 125C
M950 H0 C"out7" T1                                      ; Bed heater SSR on out7, PID from S1
M143 H0 P0 T1 S200 A0                                   ; Bed primary limit 200C on sensor S1
M143 H0 P1 T2 S125 A0                                   ; Bed mat safety cutout 125C on sensor S2
M307 H1 A100.0 C200.0 D5.0 B0                           ; Bed PID model (calculatede for 20mm granite slab)

; Map bed heater
M140 P0 H0                                              ; Map to bed slot

; ======================== Fans ========================
; Fan 0: Duet enclosure fan (Noctua NF-A4x10 24V PWM) on OUT4
; Thermostatic: off below 40C, 100% at 60C, driven by MCU and driver temps
M950 F0 C"!out4" Q500                                   ; Fan 0: enclosure fan, 500Hz PWM
M106 P0 H10:11 T25:45                                   ; Off below 40C, full at 60C, thermostatic control

; Fan 1: WS7040 CPAP (part cooling) on OUT5 with tach
M950 F1 C"out9+out5.tach" Q500 K1                      ; Fan 1: CPAP, 500Hz PWM, tach on out9 (0-5v out5.tach) with 1pprpm
M106 P1 S0 L0 X1 H-1                                   ; Manual/slicer control, no thermostatic

; Fan 2: Water pump PWM on OUT6
; Overridden by daemon.g which gates pump on hotend temp (>50C)
; Below 50C hotend: pump off. Above 50C: pump runs at 40% min, 100% at 40C coolant temp
M950 F2 C"out6" Q500                                    ; Fan 2: water pump, 500Hz PWM
M106 P2 S0 L0.4 X1 H3 T25:40 B0.1                      ; 40% min, 100% at 40C coolant temp - overridden by daemon.g

; ======================== Tools =======================
M563 P0 D0 H1 F1                                        ; Tool 0: Extruder 0, Heater 1 (hotend), Fan 1 (CPAP)
M568 P0 R0 S0                                           ; Standby/Active temps to 0C
T0                                                      ; Select Tool 0

; ======================= Inputs =======================
; Flow switch on IO4 (NC - closed = flow present)
M950 J0 C"io4.in"                                       ; Input 0: flow switch
M581 T0 P0 S0 R0                                        ; Trigger 0 on flow switch open (loss of flow)

; Filament sensor on IO3 (TBD - placeholder)
; M950 J1 C"io3.in"                                     ; Input 1: filament sensor (uncomment when fitted)

; Pause button on IO7 (NO - make to pause)
M950 J2 C"io7.in"                                       ; Input 2: pause button
M581 T2 P2 S1 R0                                        ; Trigger 2 on pause button make, during print only

; Stop button on IO8 (NC - break to stop)
M950 J3 C"!io8.in"                                       ; Input 3: stop button
M581 T3 P3 S0 R0                                        ; Trigger 3 on stop button break

; ======================= Outputs ======================
; OUT8: PLC safety relay R1 coil
; HIGH = relay latched = PLC %I0.0 healthy = heater enabled
; Drops on any Duet stop/estop condition via trigger macros
; Initialise HIGH at startup - machine in known good state
M950 P0 C"out8"                                         ; GPIO 0: PLC safety relay coil
M42 P0 S0                                               ; Hold OUT8 low until stop button confirmed

if { sensors.gpIn[3].value = 1 }
    M42 P0 S1
    M118 P0 S"[BOOT] Stop button OK - PLC relay enabled"
else
    M118 P0 S"[BOOT] Stop button open - PLC relay held off, press pause to reset"

; ======================= Modbus =======================
; RS485 to Siemens S7-1200 PLC for chamber heating control
; IO1 dedicated to RS485 - RS485_EN jumper fitted on board
M575 P2 B9600 S7                                        ; Serial 2: RS485, 9600 baud, Modbus RTU

; ===================== Finalization ===================
M98 P"vars.g"  