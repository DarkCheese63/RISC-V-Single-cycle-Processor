main:
	addi x1, x0, 1
	addi x2, x0, 1
	addi x3, x0, 1
	j skip
	nop
	addi x4, x0, 1
	addi x5, x0, 1
skip:
	addi x6, x0, 1
	addi x7, x0, 1
exit:
	wfi
