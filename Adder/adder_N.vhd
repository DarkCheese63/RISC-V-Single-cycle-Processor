-------------------------------------------------------------------------
-- Luke Olsen
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- adder.vhd
-------------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.all;

entity adder_N is
  generic(N : integer := 32);
  port(i_A          : in std_logic_vector(N-1 downto 0);
       i_B         : in std_logic_vector(N-1 downto 0);
       i_CIN         : in std_logic;
       o_SUM          : out std_logic_vector(N-1 downto 0);
       o_COUT	     : out std_logic);

end adder_N;

architecture structural of adder_N is

  component adder
    port(i_A          : in std_logic;
       i_B         : in std_logic;
       i_CIN         : in std_logic;
       o_SUM          : out std_logic;
       o_COUT	     : out std_logic);
  end component;

  signal c : std_logic_vector(N downto 0); --internal carry signal

begin
  c(0) <= i_CIN; --send in initial carry

  GEN_FULLADD : for i in 0 to N-1 generate
    N_FULLADD : adder
      port map(i_A          => i_A(i),
       i_B         => i_B(i),
       i_CIN         => c(i),
       o_SUM          => o_SUM(i),
       o_COUT	     => c(i+1));
  end generate GEN_FULLADD;

  o_COUT <= c(N); -- send out carry from result
  
end structural;
