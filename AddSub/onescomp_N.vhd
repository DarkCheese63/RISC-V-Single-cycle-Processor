-------------------------------------------------------------------------
-- Luke Olsen
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- onescomp_N.vhd
-------------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.all;

entity onescomp_N is
  generic(N : integer := 32); -- Generic of type integer for input/output data width. Default value is 32.
  port(i_A         : in std_logic_vector(N-1 downto 0);
       o_O          : out std_logic_vector(N-1 downto 0));

end onescomp_N;

architecture structural of onescomp_N is

  component invg is
    port(i_A                 : in std_logic;
         o_F                  : out std_logic);
  end component;

begin

  -- Instantiate N mux instances.
  GEN_INV: for i in 0 to N-1 generate
    N_INV: invg port map(
              i_A     => i_A(i),  -- ith instance's data 0 input hooked up to ith data 0 input.
              o_F      => o_O(i));  -- ith instance's data output hooked up to ith data output.
  end generate GEN_INV;
  
end structural;
