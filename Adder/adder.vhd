-------------------------------------------------------------------------
-- Luke Olsen
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- adder.vhd
-------------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.all;

entity adder is
  port(i_A          : in std_logic;
       i_B         : in std_logic;
       i_CIN         : in std_logic;
       o_SUM          : out std_logic;
       o_COUT	     : out std_logic);

end adder;

architecture structural of adder is

  component org2 is
    port(i_A                 : in std_logic;
         i_B                 : in std_logic;
         o_F                 : out std_logic);
  end component;

  component xorg2 is
    port(i_A                 : in std_logic;
         i_B                 : in std_logic;
         o_F                 : out std_logic);
  end component;

  component andg2 is
    port(i_A                  : in std_logic;
	 i_B		      : in std_logic;
         o_F                   : out std_logic);
  end component;

  signal s_AXB  : std_logic;
  signal s_and1 : std_logic;
  signal s_and2 : std_logic;
  signal s_SUM  : std_logic;

begin

  g_xor1: xorg2
	port MAP(i_A	=>	i_A,
		 i_B	=>	i_B,
		 o_F	=>	s_AXB);

  g_xor2: xorg2
	port MAP(i_A	=>	s_AXB,
		 i_B	=>	i_CIN,
		 o_F	=>	o_SUM);

  g_and1: andg2
	port MAP(i_A	=>	i_A,
		 i_B	=>	i_B,
		 o_F	=>	s_and1);

  g_and2: andg2
	port MAP(i_A	=>	i_CIN,
		 i_B	=>	s_AXB,
		 o_F	=>	s_and2);

  g_or: org2
	port MAP(i_A	=>	s_and1,
		 i_B	=>	s_and2,
		 o_F	=>	o_COUT);
  
end structural;
