-------------------------------------------------------------------------
-- Luke Olsen
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- extender.vhd
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity extender is
  generic(N : integer := 12);
  port(i_IN           : in std_logic_vector(N-1 downto 0);
       i_SIGN         : in std_logic;
       o_EXT	      : out std_logic_vector(31 downto 0));

end extender;

architecture dataflow of extender is
begin
  process (i_IN)
  begin
    if (i_SIGN = '1') then
      o_EXT <= (31 downto N => '1') & i_IN; -- '1' extension
    else
      o_EXT <= (31 downto N => '0') & i_IN; -- '0' extension
    end if;
  end process;
  

end dataflow;