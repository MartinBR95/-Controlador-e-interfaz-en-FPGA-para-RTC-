vsim work.top_tb
onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix binary /top_tb/RST
add wave -noupdate -radix binary /top_tb/CLK
add wave -noupdate -radix hexadecimal /top_tb/Dir
add wave -noupdate -radix hexadecimal /top_tb/Punt
add wave -noupdate -radix binary /top_tb/uut/Numup
add wave -noupdate -radix binary /top_tb/uut/Numdown
add wave -noupdate -radix binary /top_tb/CS
add wave -noupdate -radix binary /top_tb/RD
add wave -noupdate -radix binary /top_tb/WR
add wave -noupdate -radix binary /top_tb/AD
add wave -noupdate -radix binary /top_tb/uut/Acceso
add wave -noupdate -radix binary /top_tb/uut/Mod
add wave -noupdate -radix binary /top_tb/uut/FRW
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 0
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {1 ns}
run -all
