-------------------------------------------------------------------------
-- Matthew Estes
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- FetchLogic.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: this is the stuctural implementation of a single cycle riscv datapath fetch logic
--              
-- 10/07/2025
-------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity FetchLogic is
	port(
		rst    : in std_logic;
		clk    : in std_logic;
		imm    : in std_logic_vector(31 downto 0); -- immediate value branch/jump
		ALUo   : in std_logic_vector(31 downto 0); -- jalr target from alu 
		PCsrc  : in std_logic_vector(1 downto 0); -- pc select 00 = pc+4, 01 = branch, 10 = jump, 11 = jalr
		currPC : out std_logic_vector(31 downto 0); -- current pc value
		instr  : out std_logic_vector(31 downto 0) -- fetched instruction
	);
end FetchLogic;

architecture structure of FetchLogic is 

	component InstructionMemory is
		port(
        clk          :   in std_logic;
		s_IMemAddr   :   in std_logic_vector(11 downto 2); -- PC[11:2]
		iInstLd	     :	 in std_logic;
		iInstExt     :	 in std_logic_vector(31 downto 0);
		s_Inst       :   out std_logic_vector(31 downto 0) -- Instruction

	);
	end component;

	component ProgramCounter is
		port(
		clk	 	 :   in std_logic;
		rst      :   in std_logic;
		pc_in    :   in std_logic_vector(31 downto 0);
		pc_out   :   out std_logic_vector(31 downto 0)
	);
	end component;
	
	signal next_pc			:	std_logic_vector(31 downto 0);
	signal pc_plus_4		:	std_logic_vector(31 downto 0);
	signal branch_target	:	std_logic_vector(31 downto 0);
	signal jump_target		:	std_logic_vector(31 downto 0);
	signal pc_val			:	std_logic_vector(31 downto 0); 


	begin

		-- program counter
		PC: ProgramCounter
			port map(
				clk => clk,
				rst => rst,
				pc_in => next_pc,
				pc_out => pc_val
			);
		currPC <= pc_val;

		-- pc + 4
		pc_plus_4 <= std_logic_vector(unsigned(pc_val)+4);

		-- branch/jump address
		branch_target <= std_logic_vector(signed(pc_val) + signed(imm));
		jump_target <= std_logic_vector(signed(pc_val) + signed(imm));

		-- mux for next pc selection
		with PCsrc select
			next_pc <= pc_plus_4 when "00",
					   branch_target  when "01",
					   jump_target  when "10",
					   ALUo when "11",
					   (others => '0') when others;


		-- instruction memory
		iMEM: InstructionMemory
			port map(
				clk => clk,
				s_IMemAddr => pc_val(11 downto 2),
				iInstExt => (others => '0'),
				iInstLd => '0',
				s_Inst => instr
			);
end structure;
