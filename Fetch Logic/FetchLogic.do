add wave -divider "Clock and Reset"
add wave /tb_FetchLogic/clk
add wave /tb_FetchLogic/rst

add wave -divider "Inputs"
add wave /tb_FetchLogic/PCsrc
add wave /tb_FetchLogic/imm
add wave /tb_FetchLogic/ALUo

add wave -divider "Outputs"
add wave /tb_FetchLogic/currPC
add wave /tb_FetchLogic/instr

add wave -divider "Internal FetchLogic Signals"
add wave /tb_FetchLogic/DUT/pc_val
add wave /tb_FetchLogic/DUT/next_pc
add wave /tb_FetchLogic/DUT/pc_plus_4
add wave /tb_FetchLogic/DUT/branch_target
add wave /tb_FetchLogic/DUT/jump_target

run 500 ns