# --- Testbench Inputs ---
add wave -divider "TESTBENCH INPUTS"
add wave sim:/tb_ALU/i_A
add wave sim:/tb_ALU/i_B
add wave sim:/tb_ALU/Ctrl

# --- DUT Internal Signals ---
add wave -divider "DUT INTERNALS"
add wave sim:/tb_ALU/DUT/ALUCtrl
add wave sim:/tb_ALU/DUT/A
add wave sim:/tb_ALU/DUT/B

# --- DUT Outputs ---
add wave -divider "DUT OUTPUTS"
add wave sim:/tb_ALU/ALU_Result
add wave sim:/tb_ALU/o_zero

run 500 ns
