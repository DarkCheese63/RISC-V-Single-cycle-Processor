-------------------------------------------------------------------------
-- Luke Olsen
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- tb_adder.vhd
-------------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_textio.all;  -- For logic types I/O
library std;
use std.env.all;                -- For hierarchical/external signals
use std.textio.all;             -- For basic I/O

-- Usually name your testbench similar to below for clarity tb_<name>
entity tb_adder is
end tb_adder;

architecture mixed of tb_adder is

-- Define the total clock period time

-- We will be instantiating our design under test (DUT), so we need to specify its
-- component interface.
-- TODO: change component declaration as needed.
  component adder is
    port(i_A 		            : in std_logic;
    i_B 		            : in std_logic;
    i_CIN 		    : in std_logic;
    o_SUM                      : out std_logic;
    o_COUT 		            : out std_logic);
  end component;


-- TODO: change input and output signals as needed.
  signal s_A     : std_logic := '0';
  signal s_B     : std_logic := '0';
  signal s_CIN   : std_logic := '0';
  signal s_SUM   : std_logic;
  signal s_COUT  : std_logic;

begin

  -- TODO: Actually instantiate the component to test and wire all signals to the corresponding
  -- input or output. Note that DUT0 is just the name of the instance that can be seen 
  -- during simulation. What follows DUT0 is the entity name that will be used to find
  -- the appropriate library component during simulation loading.
  DUT0 : adder
  port map(
            i_A       => s_A,
            i_B       => s_B,
            i_CIN     => s_CIN,
            o_SUM     => s_SUM,
            o_COUT    => s_COUT);
  --You can also do the above port map in one line using the below format: http://www.ics.uci.edu/~jmoorkan/vhdlref/compinst.html 
  
  -- Assign inputs for each test case.
  -- TODO: add test cases as needed.
  P_TEST_CASES: process
  begin
    
  s_A <= '0';
  s_B <= '0';
  s_CIN <= '0';
  wait for 100 ns;

  s_A <= '1';
  s_B <= '0';
  s_CIN <= '0';
  wait for 100 ns;

  s_A <= '0';
  s_B <= '0';
  s_CIN <= '1';
  wait for 100 ns;

  s_A <= '1';
  s_B <= '0';
  s_CIN <= '1';
  wait for 100 ns;

  s_A <= '0';
  s_B <= '1';
  s_CIN <= '0';
  wait for 100 ns;

  s_A <= '1';
  s_B <= '1';
  s_CIN <= '0';
  wait for 100 ns;

  s_A <= '0';
  s_B <= '1';
  s_CIN <= '1';
  wait for 100 ns;

  s_A <= '1';
  s_B <= '1';
  s_CIN <= '1';
  wait for 100 ns;

    wait;
  end process;

end mixed;
