-------------------------------------------------------------------------
-- Luke Olsen
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- tb_reg_N.vhd
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_textio.all;  -- For logic types I/O
library std;
use std.env.all;                -- For hierarchical/external signals
use std.textio.all;             -- For basic I/O

-- Usually name your testbench similar to below for clarity tb_<name>
entity tb_reg_N is
  generic(N : integer := 32;
	  gCLK_HPER   : time := 50 ns);
end tb_reg_N;

architecture mixed of tb_reg_N is
   constant cCLK_PER  : time := gCLK_HPER * 2;
-- We will be instantiating our design under test (DUT), so we need to specify its
-- component interface.
-- TODO: change component declaration as needed.
  component reg_N is
    generic (N : integer := 32); 
    port(i_CLK          : in std_logic;
       i_RST          : in std_logic;
       i_WE           : in std_logic;
       i_D            : in std_logic_vector(N-1 downto 0);
       o_Q	      : out std_logic_vector(N-1 downto 0));
  end component;

-- Create signals for all of the inputs and outputs of the file that you are testing
-- := '0' or := (others => '0') just make all the signals start at an initial value of zero

-- TODO: change input and output signals as needed.
  signal s_CLK : std_logic; 
  signal s_RST : std_logic;
  signal s_WE  : std_logic;
  signal s_D   : std_logic_vector(N-1 downto 0);
  signal s_Q   : std_logic_vector(N-1 downto 0);

 begin

  -- TODO: Actually instantiate the component to test and wire all signals to the corresponding
  -- input or output. Note that DUT0 is just the name of the instance that can be seen 
  -- during simulation. What follows DUT0 is the entity name that will be used to find
  -- the appropriate library component during simulation loading.
  DUT0 : reg_N
   generic map(N => N)
   port map(i_CLK => s_CLK,
		 i_RST => s_RST,
		 i_WE  => s_WE,
		 i_D   => s_D,
		 o_Q   => s_Q);
  -- You can also do the above port map in one line using the below format: http://www.ics.uci.edu/~jmoorkan/vhdlref/compinst.html
  -- Assign inputs for each test case.
  -- This process sets the clock value (low for gCLK_HPER, then high
  -- for gCLK_HPER). Absent a "wait" command, processes restart 
  -- at the beginning once they have reached the final statement.
  P_CLK: process
  begin
    s_CLK <= '0';
    wait for gCLK_HPER;
    s_CLK <= '1';
    wait for gCLK_HPER;
  end process;

  P_TEST_CASES: process
  begin
  s_RST <= '1';
  s_WE  <= '0';
  s_D   <= x"00000000";
  wait for 100 ns;

  s_RST <= '0';
  s_WE  <= '1';
  s_D   <= x"FFFFFFFF";
  wait for 100 ns;

  s_RST <= '0';
  s_WE  <= '0';
  s_D   <= x"00000000";
  wait for 100 ns;

  s_RST <= '0';
  s_WE  <= '1';
  s_D   <= x"00000000";
  wait for 100 ns;

  s_RST <= '0';
  s_WE  <= '0';
  s_D   <= x"FFFFFFFF";
  wait for 100 ns;

    wait;
  end process;

end mixed;