-------------------------------------------------------------------------
-- Luke Olsen
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- tb_mux2to1.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains a testbench for the TPU MAC unit.
--              
-- 01/03/2020 by H3::Design created.
-- 01/16/2025 by CWS::Switched from integer to std_logic_vector.
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_textio.all;  -- For logic types I/O
library std;
use std.env.all;                -- For hierarchical/external signals
use std.textio.all;             -- For basic I/O

-- Usually name your testbench similar to below for clarity tb_<name>
entity tb_mux2to1 is
end tb_mux2to1;

architecture mixed of tb_mux2to1 is

-- We will be instantiating our design under test (DUT), so we need to specify its
-- component interface.
-- TODO: change component declaration as needed.
  component mux2to1 is
    port(i_S  : in std_logic;
       i_D0 : in std_logic;
       i_D1 : in std_logic;
       o_O  : out std_logic);
  end component;

-- Create signals for all of the inputs and outputs of the file that you are testing
-- := '0' or := (others => '0') just make all the signals start at an initial value of zero

-- TODO: change input and output signals as needed.
  signal s_S  : std_logic := '0';
  signal s_D0 : std_logic := '0';
  signal s_D1: std_logic := '0';
  signal s_O  : std_logic;

 begin

  -- TODO: Actually instantiate the component to test and wire all signals to the corresponding
  -- input or output. Note that DUT0 is just the name of the instance that can be seen 
  -- during simulation. What follows DUT0 is the entity name that will be used to find
  -- the appropriate library component during simulation loading.
  DUT0 : mux2to1
  port map(
            i_S     => s_S,
            i_D0    => s_D0,
            i_D1    => s_D1,
            o_O     => s_O);
  -- You can also do the above port map in one line using the below format: http://www.ics.uci.edu/~jmoorkan/vhdlref/compinst.html
  -- Assign inputs for each test case.
  -- TODO: add test cases as needed.
  P_TEST_CASES: process
  begin
  s_S <= '0';
  s_D0 <= '0';
  s_D1 <= '0';
  wait for 100 ns;

  s_S <= '1';
  s_D0 <= '0';
  s_D1 <= '0';
  wait for 100 ns;

  s_S <= '0';
  s_D0 <= '0';
  s_D1 <= '1';
  wait for 100 ns;

  s_S <= '1';
  s_D0 <= '0';
  s_D1 <= '1';
  wait for 100 ns;

  s_S <= '0';
  s_D0 <= '1';
  s_D1 <= '0';
  wait for 100 ns;

  s_S <= '1';
  s_D0 <= '1';
  s_D1 <= '0';
  wait for 100 ns;

  s_S <= '0';
  s_D0 <= '1';
  s_D1 <= '1';
  wait for 100 ns;

  s_S <= '1';
  s_D0 <= '1';
  s_D1 <= '1';
  wait for 100 ns;

    wait;
  end process;

end mixed;