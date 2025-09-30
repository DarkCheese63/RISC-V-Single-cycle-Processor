-------------------------------------------------------------------------
-- Joseph Zambreno
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- tb_extender.vhd
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity tb_extender is
  generic(N : integer := 12);
end tb_extender;

architecture behavior of tb_extender is

  component extender
    generic(N : integer := 12);
    port(i_IN           : in std_logic_vector(N-1 downto 0);
       i_SIGN         : in std_logic;
       o_EXT	      : out std_logic_vector(31 downto 0));
  end component;

  -- Temporary signals to connect to the dff component.
  signal s_IN  : std_logic_vector(N-1 downto 0);
  signal s_SIGN : std_logic;
  signal s_EXT : std_logic_vector(31 downto 0); 
begin

  DUT: extender 
  port map(i_IN => s_IN, 
           i_SIGN => s_SIGN,
           o_EXT   => s_EXT);
 
  -- Testbench process  
  P_TB: process
  begin
    -- test cases
    s_SIGN  <= '0';
    wait for 100 ns;
 
    s_IN <= x"000";
    wait for 100 ns;
    s_IN <= x"005";
    wait for 100 ns;
    s_IN <= x"FFF";
    wait for 100 ns;

    -- test cases
    s_SIGN  <= '1';
    wait for 100 ns;

    s_IN <= x"000";
    wait for 100 ns;
    s_IN <= x"005";
    wait for 100 ns;
    s_IN <= x"FFF";
    wait for 100 ns;

    wait;
  end process;
  
end behavior;