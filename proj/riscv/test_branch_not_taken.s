.text
.globl main
main:
    # 1. Setup Data
    addi x1, x0, 1
    addi x2, x0, 2

    # 2. The Test: 1 != 2, so Branch should NOT be taken.
    beq  x1, x2, BAD_TARGET  

    # 3. Correct Path (Fall Through)
    addi x3, x0, 5           # Should execute
    addi x4, x0, 6           # Should execute

    # 4. Safe Exit
    j    PASS_TEST           

# ----------------------------------------
# FAILURE ZONE
BAD_TARGET:
    addi x5, x0, 7           # Should NEVER execute
    wfi

# ----------------------------------------
# SUCCESS ZONE
PASS_TEST:
    wfi
