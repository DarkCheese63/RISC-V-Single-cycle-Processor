jal  x1, TARGET    # x1 should become PC+4
addi x2, x0, 0     # Flushed
TARGET:
addi x3, x0, 5
wfi
