.text
.globl main

main:
    # The 'add' needs x1 immediately. It is in the EX stage.
    # The Forwarding Unit must grab it from EX/MEM.
    addi x1, x0, 10      # x1 = 10
    add  x2, x1, x0      # x2 = x1 + 0 = 10 (Forwarded from EX)


    # The 'add' needs x3. It is in the WB stage (because of the nop).
    # The Forwarding Unit must grab it from MEM/WB.
    addi x3, x0, 20      # x3 = 20
    addi x0, x0, 0       # NOP (Buffer cycle)
    add  x4, x3, x0      # x4 = x3 + 0 = 20 (Forwarded from WB)
    
    # Tests forwarding to both ALU inputs simultaneously.
    # RS1 (x5) comes from WB. RS2 (x6) comes from EX.
    addi x5, x0, 5       # x5 = 5
    addi x6, x0, 6       # x6 = 6
    add  x7, x5, x6      # x7 = 5 + 6 = 11 (Double Forward)

    # End Program
    wfi
