.text
.globl main

main:
    la x1, TARGET       
    jalr x2, 0(x1)
    addi x10, x0, 0     # x10 = 0 means FAILURE
    beq x0, x0, END     # Skip to end

TARGET:
    addi x10, x0, 1     # x10 = 1 means SUCCESS
    addi x11, x2, 0

END:
    wfi
