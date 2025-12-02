-------------------------------------------------------------------------
-- Luke Olsen
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- Reg_IF_ID.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: 
-- NOTES:
-- 9/9/2025
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity Reg_IF_ID is 
	generic(N : integer := 32);
	port(
		i_CLK : in STD_LOGIC; -- clock input - 1 bit	
		i_RST : in STD_LOGIC; -- reset input - 1 bit
		i_WE  : in STD_LOGIC; -- Write Enable

		-- control value
		i_FLUSH  : in STD_LOGIC; -- dictates NOP: this is a control val on the pipeline reg

		-- dataflow values
		i_PC     : in std_logic_vector(N-1 downto 0);
		i_PCP4   : in std_logic_vector(N-1 downto 0); 
		i_INST   : in std_logic_vector(N-1 downto 0);

		o_PC     : out std_logic_vector(N-1 downto 0); --outputs of PC and INST regs
		o_PCP4   : out std_logic_vector(N-1 downto 0);
		o_INST   : out std_logic_vector(N-1 downto 0)
	);
end Reg_IF_ID;

architecture structure of Reg_IF_ID is 
  component Reg_N is 
	generic(N : integer := 32);
	port(
		i_CLK : in STD_LOGIC; -- clock input - 1 bit	
		i_RST : in STD_LOGIC; -- reset input - 1 bit
		i_WE  : in STD_LOGIC;
		i_D   : in std_logic_vector(N-1 downto 0);
		o_Q   : out std_logic_vector(N-1 downto 0)
	);
  end component;
  
  -- signals for output val of regs
  signal q_PC : std_logic_vector(N-1 downto 0);
  signal q_PCP4 : std_logic_vector(N-1 downto 0);
  signal q_INST : std_logic_vector(N-1 downto 0);
  
  -- signals for flush gating
  signal s_PC : std_logic_vector(N-1 downto 0);
  signal s_PCP4 : std_logic_vector(N-1 downto 0);
  signal s_INST : std_logic_vector(N-1 downto 0);

begin

  s_PC <= (others => '0') when i_FLUSH = '1' else i_PC;
  s_PCP4 <= (others => '0') when i_FLUSH = '1' else i_PCP4;
  s_INST <= (others => '0') when i_FLUSH = '1' else i_INST;

  PC_REG: Reg_N
	port map(
		i_CLK => i_CLK,
		i_RST => i_RST,
		i_WE  => i_WE,
		i_D   => s_PC,--pc value
		o_Q   => q_PC --output data
	);

  PCP4_REG: Reg_N
	port map(
		i_CLK => i_CLK,
		i_RST => i_RST,
		i_WE  => i_WE,
		i_D   => s_PCP4,--pcp4 value
		o_Q   => q_PCP4 --output data
	);

  INST_REG: Reg_N
	port map(
		i_CLK => i_CLK,
		i_RST => i_RST,
		i_WE  => i_WE,
		i_D   => s_INST,--inst value
		o_Q   => q_INST --output data
	);
	
  --outputs of this pipeline stage
  o_PC <= q_PC;
  o_PCP4 <= q_PCP4;
  o_INST <= q_INST;
	
end structure;
	
	
