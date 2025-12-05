        .data
        .align 2
wdata:  .word 0x11223344
        .align 1
hdata:  .half 0x1234
        .align 0
bdata:  .byte 0x7F
        .align 2
arr:    .space 16

        .text
        .globl main
        
#Base test showing each instruction.
main:

  	# --- LUI ---
        lui   x8, 0x12

        # --- ADDI ---
        addi  x9, x0, 5

        # --- ADD ---
        add   x10, x11, x20       # x1,x2 are never written

        # --- SUB ---
        sub   x11, x11, x20

        # --- AND ---
        and   x12, x11, x20

        # --- ANDI ---
        andi  x13, x10, 0xF

        # --- OR ---
        or    x14, x7, x8       # x8 only from LUI (safe)

        # --- ORI ---
        ori   x15, x10, 0xAA     # x2 is safe

        # --- XOR ---
        xor   x16, x10, x11

        # --- XORI ---
        xori  x17, x10, 0x55

        # --- SLL ---
        sll   x18, x10, x11       # uses x9 but x9 came from ADDI only (safe)

        # --- SLLI ---
        slli  x19, x10, 1

        # --- SRL ---
        srl   x20, x10, x11       # safe

        # --- SRLI ---
        srli  x21, x10, 1

        # --- SRA ---
        sra   x22, x10, x11

        # --- SRAI ---
        srai  x23, x10, 1

        # --- SLT ---
        slt   x24, x11, x10

        # --- SLTI ---
        slti  x25, x10, 50

        # --- SLTIU ---
        sltiu x26, x11, 50

        # --- LW --- 
	lui x1, 0x10010 # upper 20 bits 
	nop
	nop
	nop
	addi x1, x1, 0x0 # lower 12 bits 
	nop
	nop
	nop
	lw x28, 0(x1) 
	nop
	nop
	nop
	# --- SW --- 
	lui x2, 0x10010 
	nop
	nop
	nop
	addi x2, x2, 0x8 
	nop
	nop
	nop
	sw x28, 0(x2) 
	nop
	nop
	nop
	# --- LH --- 
	lui x3, 0x10010 
	nop
	nop
	nop
	addi x3, x3, 0x4 
	nop
	nop
	nop
	lh x29, 0(x3) 
	nop
	nop
	nop
	# --- LHU --- 
	lhu x30, 0(x3) 
	nop
	nop
	nop
	# --- LB --- 
	lui x4, 0x10010 
	nop
	nop
	nop
	addi x4, x4, 0x6 
	nop
	nop
	nop
	lb x31, 0(x4) 
	nop
	nop
	nop
	# --- LBU --- 
	lbu x5, 0(x4)
	nop
	nop
	nop

        # --- BEQ ---
        addi  x6, x0, 10
        addi  x7, x0, 20
        beq   x6, x6, beq_target
        nop
        nop
        nop

beq_target:
        bne   x6, x7, bne_target
        nop
        nop
        nop

bne_target:
        blt   x6, x7, blt_target
        nop
        nop
        nop

blt_target:
        bge   x7, x6, bge_target
        nop
        nop
        nop

bge_target:
        bltu  x6, x7, bltu_target
        nop
        nop
        nop

bltu_target:
        bgeu  x7, x6, bgeu_target
        nop
        nop
        nop

bgeu_target:
	nop
        jal   x1, jal_target
        nop
        nop
        nop
        j halt
        
jal_target:
	jalr zero, 0(x1)
	nop
	nop
	nop

halt:
        wfi
