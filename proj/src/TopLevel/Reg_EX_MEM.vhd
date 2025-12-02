-------------------------------------------------------------------------
-- Luke Olsen
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- Reg_EX_MEM.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: 
-- NOTES:
-- 9/9/2025
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity Reg_EX_MEM is 
	generic(N : integer := 32);
	port(
		i_CLK : in STD_LOGIC; -- clock input - 1 bit	
		i_RST : in STD_LOGIC; -- reset input - 1 bit
		i_WE  : in STD_LOGIC;
		i_FLUSH : in STD_LOGIC;
		
		--control signals from previous stage ID/EX
		i_SRegWr   : in std_logic_vector(0 downto 0); 
		i_SDMemWr  : in std_logic_vector(0 downto 0);
		i_WBSel    : in std_logic_vector(1 downto 0);
		i_SHALT	   : in std_logic_vector(0 downto 0);
		i_PCsrc	   : in std_logic_vector(1 downto 0);


		--dataflow values
		i_ALU : in std_logic_vector(N-1 downto 0); 
		i_ALUmasked : in std_logic_vector(n-1 downto 0);
		i_RS2    : in std_logic_vector(N-1 downto 0);
		i_RD	 : in std_logic_vector(4 downto 0);
		i_PCP4   : in std_logic_vector(N-1 downto 0);
		i_INST   : in std_logic_vector(N-1 downto 0);
		i_ImmOut : in std_logic_vector(N-1 downto 0); 
		i_PC	: in std_logic_vector(N-1 downto 0);
		
		--outputs
		o_SRegWr   : out std_logic; 
		o_SDMemWr  : out std_logic;
		o_WBSel    : out std_logic_vector(1 downto 0);
		o_SHALT	   : out std_logic;
		o_INST   : out std_logic_vector(N-1 downto 0);
		o_ImmOut : out std_logic_vector(N-1 downto 0);
		o_PCsrc	   : out std_logic_vector(1 downto 0);
		o_PC	: out std_logic_vector(N-1 downto 0);


		o_ALU    : out std_logic_vector(N-1 downto 0); --outputs of A and B from reg file and immgen regs
		o_ALUmasked : out std_logic_vector(N-1 downto 0);
		o_RS2    : out std_logic_vector(N-1 downto 0);
		o_RD     : out std_logic_vector(4 downto 0);
		o_PCP4   : out std_logic_vector(N-1 downto 0)
	);
end Reg_EX_MEM;

architecture structure of Reg_EX_MEM is 
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
  signal q_ALU	  : std_logic_vector(N-1 downto 0);
  signal q_ALUmasked : std_logic_vector(N-1 downto 0);
  signal q_RS2    : std_logic_vector(N-1 downto 0);
  signal q_PCP4   : std_logic_vector(N-1 downto 0);
  signal q_RD	  : std_logic_vector(4 downto 0);
  signal q_INST     : std_logic_vector(N-1 downto 0);
  signal q_ImmOut : std_logic_vector(N-1 downto 0); 
  signal q_PCsrc : std_logic_vector(1 downto 0);
  signal q_PC	: std_logic_vector(N-1 downto 0);

  
  signal q_SRegWr   : std_logic_vector(0 downto 0);
  signal q_SDMemWr  : std_logic_vector(0 downto 0);
  signal q_WBSel    : std_logic_vector(1 downto 0);
  signal q_SHALT    : std_logic_vector(0 downto 0);
  
  --flush signals
  signal s_ALU	  : std_logic_vector(N-1 downto 0);
  signal s_ALUmasked : std_logic_vector(N-1 downto 0);
  signal s_RS2    : std_logic_vector(N-1 downto 0);
  signal s_PCP4   : std_logic_vector(N-1 downto 0);
  signal s_RD	  : std_logic_vector(4 downto 0);
  signal s_INST     : std_logic_vector(N-1 downto 0);
  signal s_ImmOut : std_logic_vector(N-1 downto 0); 
  signal s_PCsrc : std_logic_vector(1 downto 0);
  signal s_PC	: std_logic_vector(N-1 downto 0);
  signal s_SRegWr   : std_logic_vector(0 downto 0);
  signal s_SDMemWr  : std_logic_vector(0 downto 0);
  signal s_WBSel    : std_logic_vector(1 downto 0);
  signal s_SHALT    : std_logic_vector(0 downto 0);
  
begin
  -- injecting zeros
  s_ALU <= (others => '0') when i_FLUSH = '1' else i_ALU;	
  s_ALUmasked <= (others => '0') when i_FLUSH = '1' else i_ALUmasked;	
  s_RS2 <= (others => '0') when i_FLUSH = '1' else i_RS2;	
  s_PCP4 <= (others => '0') when i_FLUSH = '1' else i_PCP4;	
  s_RD <= (others => '0') when i_FLUSH = '1' else i_RD;	
  s_INST <= (others => '0') when i_FLUSH = '1' else i_INST;	
  s_ImmOut <= (others => '0') when i_FLUSH = '1' else i_ImmOut;	
  s_PCsrc <= (others => '0') when i_FLUSH = '1' else i_PCsrc;	
  s_PC <= (others => '0') when i_FLUSH = '1' else i_PC;	
  s_SRegWr <= (others => '0') when i_FLUSH = '1' else i_SRegWr;	
  s_SDMemWr <= (others => '0') when i_FLUSH = '1' else i_SDMemWr;	
  s_WBSel <= (others => '0') when i_FLUSH = '1' else i_WBSel;	
  s_SHALT <= (others => '0') when i_FLUSH = '1' else i_SHALT;	



  --dataflow regs
  ALUOut_REG: Reg_N
	port map(
		i_CLK => i_CLK,
		i_RST => i_RST,
		i_WE  => i_WE,
		i_D   => s_ALU,--ALUOut value
		o_Q   => q_ALU --output data
	);
	
   ALUMasked_REG: Reg_N
	port map(
		i_CLK => i_CLK,
		i_RST => i_RST,
		i_WE  => i_WE,
		i_D   => s_ALUmasked,--ALUOut value
		o_Q   => q_ALUmasked --output data
	);

  RS2_REG: Reg_N
	port map(
		i_CLK => i_CLK,
		i_RST => i_RST,
		i_WE  => i_WE,
		i_D   => s_RS2,--RS2 value
		o_Q   => q_RS2 --output data
	);

  RD_REG: Reg_N
        generic map(N => 5)
	port map(
		i_CLK => i_CLK,
		i_RST => i_RST,
		i_WE  => i_WE,
		i_D   => s_RD, --ImmOut value
		o_Q   => q_RD  --output data
	);

  PCP4_REG: Reg_N
	port map(
		i_CLK => i_CLK,
		i_RST => i_RST,
		i_WE  => i_WE,
		i_D   => s_PCP4, --pcp4 value
		o_Q   => q_PCP4  --output data
	);
	
  INST_REG: Reg_N
	port map(
		i_CLK => i_CLK,
		i_RST => i_RST,
		i_WE  => i_WE,
		i_D   => s_INST,--inst value
		o_Q   => q_INST --output data
	);
	
  ImmOut_REG: Reg_N
	port map(
		i_CLK => i_CLK,
		i_RST => i_RST,
		i_WE  => i_WE,
		i_D   => s_ImmOut, --ImmOut value
		o_Q   => q_ImmOut  --output data
	);

  PC_REG: Reg_N
	port map(
		i_CLK => i_CLK,
		i_RST => i_RST,
		i_WE  => i_WE,
		i_D   => s_PC, --pc value
		o_Q   => q_PC  --output data
	);
	
  --control value regs
  SREGWR: Reg_N generic map(N => 1) port map(i_CLK => i_CLK,i_RST => i_RST,i_WE  => i_WE,i_D => s_SRegWr, o_Q => q_SRegWr);
  SDMEMWR: Reg_N generic map(N => 1) port map(i_CLK => i_CLK,i_RST => i_RST,i_WE  => i_WE, i_D => s_SDMemWr, o_Q => q_SDmemWr); 
  WBSEL: Reg_N generic map(N => 2) port map(i_CLK => i_CLK,i_RST => i_RST,i_WE  => i_WE, i_D => s_WBSel, o_Q => q_WBSel);
  SHALT: Reg_N generic map(N => 1) port map(i_CLK => i_CLK,i_RST => i_RST,i_WE  => i_WE, i_D => s_SHALT, o_Q => q_SHALT);
  PCSRC: Reg_N generic map(N => 2) port map(i_CLK => i_CLK,i_RST => i_RST,i_WE  => i_WE, i_D => s_PCsrc, o_Q => q_PCsrc);

  
  --output signals of this pipeline stage
  o_ALU <= q_ALU;
  o_ALUmasked <= q_ALUmasked;
  o_RS2 <= q_RS2;
  o_RD <= q_RD;
  o_PCP4 <= q_PCP4;
  o_INST <= q_INST;
  o_ImmOut <= q_ImmOut;
  o_PCsrc <= q_PCsrc;
  o_PC <= q_PC;

  
  o_SRegWr <= q_SRegWr(0);
  o_SDMemWr <= q_SDMemWr(0);
  o_WBSel <= q_WBSel;
  o_SHALT <= q_SHALT(0); 
	
end structure;
	
	
