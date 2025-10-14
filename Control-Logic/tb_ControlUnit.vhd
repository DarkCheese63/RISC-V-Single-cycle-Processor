-------------------------------------------------------------------------
-- Luke Olsen
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- tb_ControlUnit.vhd
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_textio.all;  
use IEEE.numeric_std.all;
library std;
use std.env.all;                
use std.textio.all;             

-- Usually name your testbench similar 1to below for clarity tb_<name>
entity tb_ControlUnit is

end tb_controlUnit;

architecture mixed of tb_ControlUnit is

  component ControlUnit is
		-- control data will grab these bits from bus 9[6:0] & 9[30, 14:12]. Reference schematic
	port(   c_IN : in std_logic_vector(31 downto 0); 
		ImmSel : out std_logic_vector(2 downto 0);
		s_RegWr : out std_logic;
		BrUn : out std_logic;
		Asel : out std_logic;
		Bsel : out std_logic;
		ALUSel : out std_logic_vector(3 downto 0);
		s_DMemWr : out std_logic;
		WBSel : out std_logic_vector(1 downto 0));
  end component;


-- change input and output signals as needed.
  signal c_IN : std_logic_vector(31 downto 0) := (others => '0'); 
  signal ImmSel : std_logic_vector(2 downto 0);
  signal s_RegWr : std_logic;
  signal BrUn : std_logic;
  signal Asel : std_logic;
  signal Bsel : std_logic;
  signal ALUSel : std_logic_vector(3 downto 0);
  signal s_DMemWr : std_logic;
  signal WBSel : std_logic_vector(1 downto 0);

 begin

  -- Actually instantiate the component to test and wire all signals to the corresponding input or output. 
  DUT0 : ControlUnit
   port map(
	 c_IN => c_IN,  
	 ImmSel => ImmSel,
	 s_RegWr => s_RegWr,
	 BrUn => BrUn,
	 Asel => Asel,
	 BSel => Bsel,
	 s_DMemWr => s_DMemWr,
	 WBSel => WBSel,
	 ALUSel => ALUSel);


  P_TEST_CASES: process
  begin

	-- Test cases consist of testing control for each instr type
	-- add, addi, and, andi, lui, lw, xor, xori, or, ori, slt, slti, sltiu, sll
	-- srl, sra, sw, sub, beq, bne, blt, bge, bltu, bgeu, jal, jalr, lb, lh, lbu,
	-- lhu, slli, srli, srai, auipc, wfi (or HALT)
	c_IN <= x"00000033";
	wait for 100 ns;


    wait;
  end process;

end mixed;