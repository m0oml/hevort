M203 X60000 Y48000        ; 1000 mm/s ceiling
M201 X20000 Y10000        ; 20,000 mm/s^2
G90                        ; absolute positioning

M203 X60000 Y60000        ; 1000 mm/s ceiling
M201 X20000 Y20000        ; 20,000 mm/s^2
G90                        ; absolute positioning

G0 X10 Y10 F48000
G0 X350 Y10 F48000
G0 X350 Y350 F48000
G0 X10  Y350 F48000
