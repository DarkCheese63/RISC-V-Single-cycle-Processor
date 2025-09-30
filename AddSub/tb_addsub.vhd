-------------------------------------------------------------------------
-- Luke Olsen
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- tb_addsub.vhd
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_textio.all;  -- For logic types I/O
library std;
use std.env.all;                -- For hierarchical/external signals
use std.textio.all;             -- For basic I/O

-- Usually name your testbench similar to below for clarity tb_<name>
entity tb_addsub is
  generic(N : integer := 32);
end tb_addsub;

architecture mixed of tb_addsub is

-- We will be instantiating our design under test (DUT), so we need to specify its
-- component interface.
-- TODO: change component declaration as needed.
  component addsub is
    generic (N : integer := 32); 
    port (i_A  : in std_logic_vector(N-1 downto 0);
         i_B : in std_logic_vector(N-1 downto 0);
         i_addsub : in std_logic;
         o_SUM  : out std_logic_vector(N-1 downto 0);
	 o_COUT  : out std_logic);
  end component;

-- Create signals for all of the inputs and outputs of the file that you are testing
-- := '0' or := (others => '0') just make all the signals start at an initial value of zero

-- TODO: change input and output signals as needed.
  signal s_A  : std_logic_vector(N-1 downto 0) := x"00000000";
  signal s_B : std_logic_vector(N-1 downto 0) := x"00000000"; 
  signal s_SUM : std_logic_vector(N-1 downto 0) := x"00000000"; 
  signal s_CIN : std_logic := '0';
  signal s_COUT  : std_logic;
  signal s_addsub  : std_logic := '0';

 begin

  -- TODO: Actually instantiate the component to test and wire all signals to the corresponding
  -- input or output. Note that DUT0 is just the name of the instance that can be seen 
  -- during simulation. What follows DUT0 is the entity name that will be used to find
  -- the appropriate library component during simulation loading.
  DUT0 : addsub
   generic map(N => N)
   port map(i_A     => s_A,
           i_B    => s_B,
           i_addsub    => s_addsub,
           o_SUM     => s_SUM,
	   o_COUT => s_COUT);
  -- You can also do the above port map in one line using the below format: http://www.ics.uci.edu/~jmoorkan/vhdlref/compinst.html
  -- Assign inputs for each test case.
  -- TODO: add test cases as needed.
  P_TEST_CASES: process
  begin
  s_A <= x"00000005";
  s_B <= x"00000003";
  s_CIN <= '0';
  s_addsub <= '0';
  wait for 100 ns;
  --expected 00000008

  s_A <= x"00000067";
  s_B <= x"00001200";
  s_CIN <= '0';
  s_addsub <= '1';
  wait for 100 ns;
  --expected FFFFEE67

  s_A <= x"01000000";
  s_B <= x"00001200";
  s_CIN <= '0';
  s_addsub <= '0';
  wait for 100 ns;

  s_A <= x"00001000";
  s_B <= x"00001002";
  s_CIN <= '0';
  s_addsub <= '0';
  wait for 100 ns;


  s_A <= x"00000067";
  s_B <= x"00000000";
  s_CIN <= '0';
  s_addsub <= '1';
  wait for 100 ns;
  

  s_A <= x"00000000";
  s_B <= x"00001200";
  s_CIN <= '0';
  s_addsub <= '1';
  wait for 100 ns;

  s_A <= x"01000000";
  s_B <= x"00010000";
  s_CIN <= '0';
  s_addsub <= '1';
  wait for 100 ns;

  s_A <= x"00003330";
  s_B <= x"00007770";
  s_CIN <= '0';
  s_addsub <= '0';
  wait for 100 ns;

    wait;
  end process;

end mixed;
