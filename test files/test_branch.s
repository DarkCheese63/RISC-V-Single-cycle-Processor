addi x1, x0, 1
addi x2, x0, 1
beq  x1, x2, TARGET  # Branch Taken!
addi x3, x0, 5       # Should be FLUSHED
addi x4, x0, 6       # Should be FLUSHED
TARGET:
addi x5, x0, 7       # Should execute
halt
