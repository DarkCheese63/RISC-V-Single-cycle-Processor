.data
    my_var: .word 0          # Safe memory location

.text
.globl main
main:
    # 1. Setup
    addi x10, x0, 10         # Target value = 10
    la   x2,  my_var         # Load address of valid memory

    # 2. Store Data
    sw   x10, 0(x2)          # Mem[my_var] = 10

    # 3. TRIGGER LOAD-USE HAZARD
    lw   x1, 0(x2)           # x1 = 10 (Stall required next cycle)

    # 4. TRIGGER CONTROL HAZARD
    # Processor must Stall 1 cycle for LW, then Forward x1, then Branch.
    beq  x1, x10, TARGET     # 10 == 10. Branch MUST be taken.

    # 5. Flush Zone
    addi x5, x0, 99          # If x5=99, the test failed.
    j    DONE                # Safety jump

TARGET:
    addi x3, x0, 5           # Success! x3=5

DONE:
    wfi
