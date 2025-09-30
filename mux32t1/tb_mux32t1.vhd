-------------------------------------------------------------------------
-- Luke Olsen
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- tb_mux32t1.vhd
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_textio.all;  -- For logic types I/O
use IEEE.numeric_std.all;
library std;
use std.env.all;                -- For hierarchical/external signals
use std.textio.all;             -- For basic I/O

-- Usually name your testbench similar to below for clarity tb_<name>
-- TODO FIX ME TO DECODER TB
entity tb_mux32t1 is
	generic (N : integer := 32; 
		I : integer := 5); 
end tb_mux32t1;

architecture mixed of tb_mux32t1 is
-- We will be instantiating our design under test (DUT), so we need to specify its
-- component interface.
-- TODO: change component declaration as needed.
  component mux32t1 is
    generic (N : integer := 32; 
		I : integer := 5); 
    port(reg0, reg1, reg2, reg3, reg4, reg5, reg6, reg7, reg8, reg9, reg10,
	     reg11, reg12, reg13, reg14, reg15, reg16, reg17, reg18, reg19, reg20,
	     reg21, reg22, reg23, reg24, reg25, reg26, reg27, reg28, reg29, reg30, reg31   : in std_logic_vector(N-1 downto 0);
	     i_S   : in std_logic_vector(I-1 downto 0);
	     f_OUT : out std_logic_vector(N-1 downto 0));
  end component;

-- Create signals for all of the inputs and outputs of the file that you are testing
-- := '0' or := (others => '0') just make all the signals start at an initial value of zero
  type reg_array_t is array (0 to 31) of std_logic_vector(N-1 downto 0);

-- TODO: change input and output signals as needed.
  signal s_reg : reg_array_t;
  signal s_S   : std_logic_vector(I-1 downto 0);
  signal s_OUT   : std_logic_vector(N-1 downto 0);

 begin

  -- TODO: Actually instantiate the component to test and wire all signals to the corresponding
  -- input or output. Note that DUT0 is just the name of the instance that can be seen 
  -- during simulation. What follows DUT0 is the entity name that will be used to find
  -- the appropriate library component during simulation loading.
  DUT0 : mux32t1 
   generic map(N => N, I => I)
   port map(i_S => s_S,
	reg0  => s_reg(0),  reg1  => s_reg(1),  reg2  => s_reg(2),  reg3  => s_reg(3),
      reg4  => s_reg(4),  reg5  => s_reg(5),  reg6  => s_reg(6),  reg7  => s_reg(7),
      reg8  => s_reg(8),  reg9  => s_reg(9),  reg10 => s_reg(10), reg11 => s_reg(11),
      reg12 => s_reg(12), reg13 => s_reg(13), reg14 => s_reg(14), reg15 => s_reg(15),
      reg16 => s_reg(16), reg17 => s_reg(17), reg18 => s_reg(18), reg19 => s_reg(19),
      reg20 => s_reg(20), reg21 => s_reg(21), reg22 => s_reg(22), reg23 => s_reg(23),
      reg24 => s_reg(24), reg25 => s_reg(25), reg26 => s_reg(26), reg27 => s_reg(27),
      reg28 => s_reg(28), reg29 => s_reg(29), reg30 => s_reg(30), reg31 => s_reg(31),
	    f_OUT => s_OUT);
  -- You can also do the above port map in one line using the below format: http://www.ics.uci.edu/~jmoorkan/vhdlref/compinst.html
  -- Assign inputs for each test case.
  P_INIT: process
  begin
    for i in 0 to 31 loop
      s_reg(i) <= std_logic_vector(to_unsigned(i, N));  -- each reg gets its index
    end loop;
    wait;
  end process;


  P_TEST_CASES: process
  begin
	-- used genAI to generate 32 lines cause its repetitive
	s_S <= "00000"; wait for 100 ns;
    s_S <= "00001"; wait for 100 ns;
    s_S <= "00010"; wait for 100 ns;
    s_S <= "00011"; wait for 100 ns;
    s_S <= "00100"; wait for 100 ns;
    s_S <= "00101"; wait for 100 ns;
    s_S <= "00110"; wait for 100 ns;
    s_S <= "00111"; wait for 100 ns;
    s_S <= "01000"; wait for 100 ns;
    s_S <= "01001"; wait for 100 ns;
    s_S <= "01010"; wait for 100 ns;
    s_S <= "01011"; wait for 100 ns;
    s_S <= "01100"; wait for 100 ns;
    s_S <= "01101"; wait for 100 ns;
    s_S <= "01110"; wait for 100 ns;
    s_S <= "01111"; wait for 100 ns;
    s_S <= "10000"; wait for 100 ns;
    s_S <= "10001"; wait for 100 ns;
    s_S <= "10010"; wait for 100 ns;
    s_S <= "10011"; wait for 100 ns;
    s_S <= "10100"; wait for 100 ns;
    s_S <= "10101"; wait for 100 ns;
    s_S <= "10110"; wait for 100 ns;
    s_S <= "10111"; wait for 100 ns;
    s_S <= "11000"; wait for 100 ns;
    s_S <= "11001"; wait for 100 ns;
    s_S <= "11010"; wait for 100 ns;
    s_S <= "11011"; wait for 100 ns;
    s_S <= "11100"; wait for 100 ns;
    s_S <= "11101"; wait for 100 ns;
    s_S <= "11110"; wait for 100 ns;
    s_S <= "11111"; wait for 100 ns;

    wait;
  end process;

end mixed;