addi x2, x0, 4     # Setup address
sw   x10, 0(x2)    # Store 10 at address 4
lw   x1, 0(x2)     # Load 10 into x1
add  x3, x1, x0    # Use x1 immediately (Must STALL here!)
halt
