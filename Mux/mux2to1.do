add wave -divider "MUX Inputs"
add wave sim:/tb_mux2to1/s_S
add wave sim:/tb_mux2to1/s_D0
add wave sim:/tb_mux2to1/s_D1

add wave -divider "MUX Output"
add wave sim:/tb_mux2to1/s_O

run 100
