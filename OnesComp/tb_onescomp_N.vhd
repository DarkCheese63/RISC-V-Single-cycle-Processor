-------------------------------------------------------------------------
-- Luke Olsen
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- tb_onescomp_N.vhd
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_textio.all;  -- For logic types I/O
library std;
use std.env.all;                -- For hierarchical/external signals
use std.textio.all;             -- For basic I/O

-- Usually name your testbench similar to below for clarity tb_<name>
entity tb_onescomp_N is
  generic(N : integer := 32);
end tb_onescomp_N;

architecture mixed of tb_onescomp_N is

-- We will be instantiating our design under test (DUT), so we need to specify its
-- component interface.
-- TODO: change component declaration as needed.
  component onescomp_N is
    generic(N : integer := 32); 
    port(i_A : in std_logic_vector(N-1 downto 0);
         o_O  : out std_logic_vector(N-1 downto 0));
  end component;

-- Create signals for all of the inputs and outputs of the file that you are testing
-- := '0' or := (others => '0') just make all the signals start at an initial value of zero

-- TODO: change input and output signals as needed.
  signal s_A : std_logic_vector(N-1 downto 0) := x"00000000"; --(others => '0'); --this allows to set all bits to 0 regardless of width
  signal s_O  : std_logic_vector(N-1 downto 0);

 begin

  -- TODO: Actually instantiate the component to test and wire all signals to the corresponding
  -- input or output. Note that DUT0 is just the name of the instance that can be seen 
  -- during simulation. What follows DUT0 is the entity name that will be used to find
  -- the appropriate library component during simulation loading.
  DUT0 : onescomp_N
  generic map(N => N)
  port map(i_A    => s_A,
           o_O     => s_O);
  -- You can also do the above port map in one line using the below format: http://www.ics.uci.edu/~jmoorkan/vhdlref/compinst.html
  -- Assign inputs for each test case.
  -- TODO: add test cases as needed.
  P_TEST_CASES: process
  begin
  s_A <= x"00000000";
  wait for 100 ns;
  --expected FFFFFFFF

  s_A <= x"FFFFFFFF";
  wait for 100 ns;
  --expected 00000000

  s_A <= x"AAAAAAAA";
  wait for 100 ns;
  --expected 01010101

  s_A <= x"1234FF01";
  wait for 100 ns;
  --expected 1C

    wait;
  end process;

end mixed;
