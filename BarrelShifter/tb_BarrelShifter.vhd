-------------------------------------------------------------------------
-- Luke Olsen
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- tb_barrelshifter.vhd
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_textio.all;  
use IEEE.numeric_std.all;
library std;
use std.env.all;                
use std.textio.all;             

-- Usually name your testbench similar 1to below for clarity tb_<name>
entity tb_barrelShifter is
	generic(N : integer := 32;
	  ALUWIDTH : integer := 4);
end tb_barrelShifter;

architecture mixed of tb_barrelShifter is

  component barrelShifter is
		-- control data will grab these bits from bus 9[6:0] & 9[30, 14:12]. Reference schematic
	  port(ALUsel         : in std_logic_vector(ALUWIDTH-1 downto 0);
       iA               : in std_logic_vector(N-1 downto 0); --input a
       iB               : in std_logic_vector(N-1 downto 0); --input b
       ALU               : out std_logic_vector(N-1 downto 0)); --output 
  end component;


-- change input and output signals as needed.
  signal ALUsel : std_logic_vector(ALUWIDTH-1 downto 0);
  signal iA : std_logic_vector(N-1 downto 0); 
  signal iB : std_logic_vector(N-1 downto 0);
  signal ALU : std_logic_vector(N-1 downto 0);

 begin

  -- Actually instantiate the component to test and wire all signals to the corresponding input or output. 
  DUT0 : barrelShifter
   port map(
	 ALUsel => ALUsel,
	 iA => iA,
	 iB => iB,
	 ALU => ALU);


  P_TEST_CASES: process
  begin

	iA <= (others => '0');
	iB <= (others => '0');
	ALUsel <= (others => '0');
	wait for 100 ns;
    -------------------------------------------------------------------
    -- Logical Left Shift (SLL)
    -------------------------------------------------------------------
    ALUsel <= "0111";   -- opcode for SLL
    iA <= x"00000003";  -- binary 000...0011
    iB <= x"00000002";  -- shift left by 2 ? expect 000...1100
    wait for 100 ns;


    -------------------------------------------------------------------
    -- Logical Right Shift (SRL)
    -------------------------------------------------------------------
    ALUsel <= "1000";   -- opcode for SRL
    iA <= x"00000010";  -- binary 000...10000
    iB <= x"00000002";  -- shift right by 2 ? expect 000...0010
    wait for 100 ns;


    -------------------------------------------------------------------
    -- Arithmetic Right Shift (SRA)
    -------------------------------------------------------------------
    ALUsel <= "1001";   -- opcode for SRA
    iA <= x"FFFFFFF0";  -- negative number (-16 signed)
    iB <= x"00000002";  -- shift right by 2 ? expect 0xFFFFFFFC (-4)
    wait for 100 ns;


    -------------------------------------------------------------------
    -- Edge Case: Shift by 0
    -------------------------------------------------------------------
    ALUsel <= "0111";   -- SLL
    iA <= x"0000000F";
    iB <= x"00000000";
    wait for 100 ns;


    -------------------------------------------------------------------
    -- Edge Case: Shift by max (31)
    -------------------------------------------------------------------
    ALUsel <= "1000";   -- SRL
    iA <= x"80000000";
    iB <= x"0000001F";  -- shift by 31 ? expect 0x00000001
    wait for 100 ns;
  


    wait;
  end process;

end mixed;