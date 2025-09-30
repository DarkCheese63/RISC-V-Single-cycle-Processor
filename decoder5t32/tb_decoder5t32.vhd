-------------------------------------------------------------------------
-- Luke Olsen
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- tb_decoder5t32.vhd
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_textio.all;  -- For logic types I/O
library std;
use std.env.all;                -- For hierarchical/external signals
use std.textio.all;             -- For basic I/O

-- Usually name your testbench similar to below for clarity tb_<name>
entity tb_decoder5t32 is
	generic (N : integer := 32; 
		I : integer := 5); 
end tb_decoder5t32;

architecture mixed of tb_decoder5t32 is
-- We will be instantiating our design under test (DUT), so we need to specify its
-- component interface.
-- TODO: change component declaration as needed.
  component decoder5t32 is
    generic (N : integer := 32; 
		I : integer := 5); 
    port(d_IN            : in std_logic_vector(I-1 downto 0);
       	 f_OUT	         : out std_logic_vector(N-1 downto 0));
  end component;

-- Create signals for all of the inputs and outputs of the file that you are testing
-- := '0' or := (others => '0') just make all the signals start at an initial value of zero

-- TODO: change input and output signals as needed.
  signal s_IN   : std_logic_vector(I-1 downto 0);
  signal s_OUT   : std_logic_vector(N-1 downto 0);

 begin

  -- TODO: Actually instantiate the component to test and wire all signals to the corresponding
  -- input or output. Note that DUT0 is just the name of the instance that can be seen 
  -- during simulation. What follows DUT0 is the entity name that will be used to find
  -- the appropriate library component during simulation loading.
  DUT0 : decoder5t32
   generic map(N => N, I => I)
   port map(d_IN => s_IN,
	    f_OUT => s_OUT);
  -- You can also do the above port map in one line using the below format: http://www.ics.uci.edu/~jmoorkan/vhdlref/compinst.html
  -- Assign inputs for each test case.

  P_TEST_CASES: process
  begin
	-- used genAI to generate 32 lines cause its repetitive
    s_IN <= "00000"; wait for 100 ns;
    s_IN <= "00001"; wait for 100 ns;
    s_IN <= "00010"; wait for 100 ns;
    s_IN <= "00011"; wait for 100 ns;
    s_IN <= "00100"; wait for 100 ns;
    s_IN <= "00101"; wait for 100 ns;
    s_IN <= "00110"; wait for 100 ns;
    s_IN <= "00111"; wait for 100 ns;
    s_IN <= "01000"; wait for 100 ns;
    s_IN <= "01001"; wait for 100 ns;
    s_IN <= "01010"; wait for 100 ns;
    s_IN <= "01011"; wait for 100 ns;
    s_IN <= "01100"; wait for 100 ns;
    s_IN <= "01101"; wait for 100 ns;
    s_IN <= "01110"; wait for 100 ns;
    s_IN <= "01111"; wait for 100 ns;
    s_IN <= "10000"; wait for 100 ns;
    s_IN <= "10001"; wait for 100 ns;
    s_IN <= "10010"; wait for 100 ns;
    s_IN <= "10011"; wait for 100 ns;
    s_IN <= "10100"; wait for 100 ns;
    s_IN <= "10101"; wait for 100 ns;
    s_IN <= "10110"; wait for 100 ns;
    s_IN <= "10111"; wait for 100 ns;
    s_IN <= "11000"; wait for 100 ns;
    s_IN <= "11001"; wait for 100 ns;
    s_IN <= "11010"; wait for 100 ns;
    s_IN <= "11011"; wait for 100 ns;
    s_IN <= "11100"; wait for 100 ns;
    s_IN <= "11101"; wait for 100 ns;
    s_IN <= "11110"; wait for 100 ns;
    s_IN <= "11111"; wait for 100 ns;

    wait;
  end process;

end mixed;