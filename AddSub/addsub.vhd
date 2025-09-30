-------------------------------------------------------------------------
-- Luke Olsen
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- addsub.vhd
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity addsub is
  generic(N : integer := 32);
  port(i_A          : in std_logic_vector(N-1 downto 0);
       i_B         : in std_logic_vector(N-1 downto 0);
       i_addsub       : in std_logic;
       o_SUM          : out std_logic_vector(N-1 downto 0);
       o_COUT	     : out std_logic);

end addsub;

architecture structural of addsub is

  component onescomp_N is
  generic(N : integer := 32);
    port(i_A          : in std_logic_vector(N-1 downto 0);
         o_O         : out std_logic_vector(N-1 downto 0));
  end component;

  component mux2t1_N is
  generic(N : integer := 32);
    port(i_S          : in std_logic;
         i_D0         : in std_logic_vector(N-1 downto 0);
	 i_D1	      : in std_logic_vector(N-1 downto 0);
	 o_O	      : out std_logic_vector(N-1 downto 0));
  end component;

  component adder_N is
  generic(N : integer := 32);
    port(i_A          : in std_logic_vector(N-1 downto 0);
         i_B         : in std_logic_vector(N-1 downto 0);
	 i_CIN	      : in std_logic;
	 o_SUM	      : out std_logic_vector(N-1 downto 0);
	 o_COUT		: out std_logic);
  end component;

  signal s_sel : std_logic_vector(N-1 downto 0);
  signal s_not : std_logic_vector(N-1 downto 0);
begin
  INV : onescomp_N
	generic map(N => N)
	port map(i_A => i_B,
		 o_O => s_not);

  MUX : mux2t1_N
	generic map(N => N)
	port map(i_S => i_addsub,
		 i_D0 => i_B,
		 i_D1 => s_not,
		 o_O => s_sel);

  ADD : adder_N
	generic map(N => N)
	port map(i_A => i_A,
		 i_B => s_sel,
		 i_CIN => i_addsub,
		 o_SUM => o_SUM,
		 o_COUT => o_COUT);
end structural;