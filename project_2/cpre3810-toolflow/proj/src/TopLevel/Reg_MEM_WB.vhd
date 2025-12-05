-------------------------------------------------------------------------
-- Luke Olsen
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- Reg_MEM_WB.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: 
-- NOTES:
-- 9/9/2025
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity Reg_MEM_WB is 
	generic(N : integer := 32);
	port(
		i_CLK : in STD_LOGIC; -- clock input - 1 bit	
		i_RST : in STD_LOGIC; -- reset input - 1 bit
		i_WE  : in STD_LOGIC;
		
		--control signals from previous stage ID/EX
		i_SRegWr   : in std_logic_vector(0 downto 0); 
		i_WBSel    : in std_logic_vector(1 downto 0);
		i_SHALT	   : in std_logic_vector(0 downto 0);

		--dataflow values
		i_ALU : in std_logic_vector(N-1 downto 0); 
		i_PCP4   : in std_logic_vector(N-1 downto 0);
		i_SDMemOut : in std_logic_vector(N-1 downto 0);
		i_ImmOut : in std_logic_vector(N-1 downto 0);
		i_RD	 : in std_logic_vector(4 downto 0);
		i_INST   : in std_logic_vector(N-1 downto 0);
		
		--outputs
		o_SRegWr   : out std_logic; 
		o_WBSel    : out std_logic_vector(1 downto 0);
		o_SHALT	   : out std_logic;
		o_INST   : out std_logic_vector(N-1 downto 0);

		o_ALU    : out std_logic_vector(N-1 downto 0); 
		o_PCP4   : out std_logic_vector(N-1 downto 0);
		o_SDMemOut : out std_logic_vector(N-1 downto 0);
		o_RD     : out std_logic_vector(4 downto 0);
		o_ImmOut : out std_logic_vector(N-1 downto 0)
	);
end Reg_MEM_WB;

architecture structure of Reg_MEM_WB is 
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
  
  
  --internal reg signals
  signal q_ALU	    : std_logic_vector(N-1 downto 0);
  signal q_SDmemOut : std_logic_vector(N-1 downto 0);
  signal q_PCP4     : std_logic_vector(N-1 downto 0);
  signal q_ImmOut   : std_logic_vector(N-1 downto 0);
  signal q_RD	  : std_logic_vector(4 downto 0);
  signal q_INST     : std_logic_vector(N-1 downto 0);
  
  --internal control value signals
  signal q_SRegWr   : std_logic_vector(0 downto 0);
  signal q_WBSel    : std_logic_vector(1 downto 0);
  signal q_SHALT    : std_logic_vector(0 downto 0);
  
begin

  --dataflow regs
  ALUOut_REG: Reg_N
	port map(
		i_CLK => i_CLK,
		i_RST => i_RST,
		i_WE  => i_WE,
		i_D   => i_ALU,--ALUOut value
		o_Q   => q_ALU --output data
	);

  DMEM_REG: Reg_N
	port map(
		i_CLK => i_CLK,
		i_RST => i_RST,
		i_WE  => i_WE,
		i_D   => i_SDMemOut,--RS2 value
		o_Q   => q_SDMemOut --output data
	);

  IMM_REG: Reg_N
	port map(
		i_CLK => i_CLK,
		i_RST => i_RST,
		i_WE  => i_WE,
		i_D   => i_ImmOut, --ImmOut value
		o_Q   => q_ImmOut  --output data
	);

  PCP4_REG: Reg_N
	port map(
		i_CLK => i_CLK,
		i_RST => i_RST,
		i_WE  => i_WE,
		i_D   => i_PCP4, --pcp4 value
		o_Q   => q_PCP4  --output data
	);
	
  RD_REG: Reg_N
        generic map(N => 5)
	port map(
		i_CLK => i_CLK,
		i_RST => i_RST,
		i_WE  => i_WE,
		i_D   => i_RD, --ImmOut value
		o_Q   => q_RD  --output data
	);

  INST_REG: Reg_N
	port map(
		i_CLK => i_CLK,
		i_RST => i_RST,
		i_WE  => i_WE,
		i_D   => i_INST,--inst value
		o_Q   => q_INST --output data
	);
	
  --control value regs
  SREGWR: Reg_N generic map(N => 1) port map(i_CLK => i_CLK,i_RST => i_RST,i_WE  => i_WE,i_D => i_SRegWr, o_Q => q_SRegWr);
  WBSEL: Reg_N generic map(N => 2) port map(i_CLK => i_CLK,i_RST => i_RST,i_WE  => i_WE, i_D => i_WBSel, o_Q => q_WBSel);
  SHALT: Reg_N generic map(N => 1) port map(i_CLK => i_CLK,i_RST => i_RST,i_WE  => i_WE, i_D => i_SHALT, o_Q => q_SHALT);
  
  
  --output signals of this pipeline stage
  o_ALU <= q_ALU;
  o_PCP4 <= q_PCP4;
  o_SDMemOut <= q_SDMemOut;
  o_ImmOut <= q_ImmOut;
  o_RD <= q_RD;
  o_INST <= q_INST;
  
  o_SRegWr <= q_SRegWr(0);
  o_WBSel <= q_WBSel;
  o_SHALT <= q_SHALT(0); 
	
end structure;
	
	
