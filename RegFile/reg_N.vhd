-------------------------------------------------------------------------
-- Luke Olsen
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- reg_N.vhd
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity reg_N is
  generic(N : integer := 32);
  port(i_CLK          : in std_logic;
       i_RST          : in std_logic;
       i_WE           : in std_logic;
       i_D            : in std_logic_vector(N-1 downto 0);
       o_Q	      : out std_logic_vector(N-1 downto 0));

end reg_N;

architecture structural of reg_N is
begin
  process (i_CLK, i_RST)
  begin
    if (i_RST = '1') then
      o_Q <= (others => '0'); --for N-bit values
    elsif (rising_edge(i_CLK)) then
      o_Q <= i_D;
    end if;

  end process;
  

end structural;