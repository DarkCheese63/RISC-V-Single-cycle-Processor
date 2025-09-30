add wave -divider "MUX Inputs"
add wave sim:/tb_mux2t1/s_S
add wave sim:/tb_mux2t1/s_D0
add wave sim:/tb_mux2t1/s_D1

add wave -divider "MUX Output"
add wave sim:/tb_mux2t1_N/s_O

run 100
