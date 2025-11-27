-------------------------------------------------------------------------
-- Luke Olsen
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- Reg_ID_EX.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: 
-- NOTES:
-- 9/9/2025
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity Reg_ID_EX is 
	generic(N : integer := 32);
	port(
		i_CLK   : in STD_LOGIC; -- clock input - 1 bit	
		i_RST   : in STD_LOGIC; -- reset input - 1 bit
		i_WE    : in STD_LOGIC;
		i_FLUSH : in STD_LOGIC;

		-- Signals from control unit, all are here except ImmSel since it is used in ID stage right when its produced
		i_SRegWr   : in std_logic_vector(0 downto 0); 
		i_BrUn     : in std_logic_vector(0 downto 0);
		i_Asel     : in std_logic_vector(0 downto 0);
		i_Bsel     : in std_logic_vector(0 downto 0);
		i_funct3   : in std_logic_vector(2 downto 0);
		i_ALUSel   : in std_logic_vector(3 downto 0);
		i_SDMemWr  : in std_logic_vector(0 downto 0);
		i_WBSel    : in std_logic_vector(1 downto 0);
		i_SHALT	   : in std_logic_vector(0 downto 0);
		i_BR	   : in std_logic_vector(0 downto 0); 
		i_MemRead  : in std_logic_vector(0 downto 0);
		-- addresses for forwarding
		i_RS1_Addr : in std_logic_vector(4 downto 0);
        	i_RS2_Addr : in std_logic_vector(4 downto 0);

		-- dataflow values
		i_RS1    : in std_logic_vector(N-1 downto 0); 
		i_RS2    : in std_logic_vector(N-1 downto 0);
		i_PC     : in std_logic_vector(N-1 downto 0);
		i_PCP4   : in std_logic_vector(N-1 downto 0);
		i_ImmOut : in std_logic_vector(N-1 downto 0); 
		i_RD	 : in std_logic_vector(4 downto 0);
		i_INST   : in std_logic_vector(N-1 downto 0);

		o_RS1    : out std_logic_vector(N-1 downto 0); 
		o_RS2    : out std_logic_vector(N-1 downto 0);
		o_PC     : out std_logic_vector(N-1 downto 0);
		o_PCP4   : out std_logic_vector(N-1 downto 0);
		o_ImmOut : out std_logic_vector(N-1 downto 0);
		o_RD	 : out std_logic_vector(4 downto 0);
		o_INST   : out std_logic_vector(N-1 downto 0);
		
		o_RS1_Addr : out std_logic_vector(4 downto 0);
        	o_RS2_Addr : out std_logic_vector(4 downto 0);
		
		o_SRegWr   : out std_logic;
		o_BrUn     : out std_logic;
		o_Asel     : out std_logic;
		o_Bsel     : out std_logic;
		o_funct3   : out std_logic_vector(2 downto 0);
		o_ALUSel   : out std_logic_vector(3 downto 0);
		o_SDMemWr  : out std_logic;
		o_WBSel    : out std_logic_vector(1 downto 0);
		o_SHALT	   : out std_logic;
		o_BR	   : out std_logic; 
		o_MemRead  : out std_logic_vector(0 downto 0)
	);
end Reg_ID_EX;

architecture structure of Reg_ID_EX is 
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
  signal q_RS1    : std_logic_vector(N-1 downto 0); 
  signal q_RS2    : std_logic_vector(N-1 downto 0);
  signal q_PC     : std_logic_vector(N-1 downto 0);
  signal q_PCP4   : std_logic_vector(N-1 downto 0);
  signal q_ImmOut : std_logic_vector(N-1 downto 0); 
  signal q_RD	  : std_logic_vector(4 downto 0);
  
  --internal control unit signals (Not to be confused with control for this pipeline reg)
  signal q_SRegWr   : std_logic_vector(0 downto 0);
  signal q_BrUn     : std_logic_vector(0 downto 0);
  signal q_Asel     : std_logic_vector(0 downto 0);
  signal q_Bsel     : std_logic_vector(0 downto 0);
  signal q_funct3   : std_logic_vector(2 downto 0);
  signal q_ALUSel   : std_logic_vector(3 downto 0);
  signal q_SDMemWr  : std_logic_vector(0 downto 0);
  signal q_WBSel    : std_logic_vector(1 downto 0);
  signal q_SHALT    : std_logic_vector(0 downto 0);
  signal q_BR	    : std_logic_vector(0 downto 0);
  signal q_MemRead  : std_logic_vector(0 downto 0);
  signal q_INST     : std_logic_vector(N-1 downto 0);
  
  signal q_RS1_Addr : std_logic_vector(4 downto 0);
  signal q_RS2_Addr : std_logic_vector(4 downto 0);
  signal s_RS1_Addr : std_logic_vector(4 downto 0);
  signal s_RS2_Addr : std_logic_vector(4 downto 0);

 --signals for flush control
  signal s_RS1    : std_logic_vector(N-1 downto 0); 
  signal s_RS2    : std_logic_vector(N-1 downto 0);
  signal s_PC     : std_logic_vector(N-1 downto 0);
  signal s_PCP4   : std_logic_vector(N-1 downto 0);
  signal s_ImmOut : std_logic_vector(N-1 downto 0); 
  signal s_RD	  : std_logic_vector(4 downto 0);
  signal s_INST   : std_logic_vector(N-1 downto 0);
  
  signal s_SRegWr   : std_logic_vector(0 downto 0); --correct sizes
  signal s_BrUn     : std_logic_vector(0 downto 0);
  signal s_Asel     : std_logic_vector(0 downto 0);
  signal s_Bsel     : std_logic_vector(0 downto 0);
  signal s_funct3   : std_logic_vector(2 downto 0);
  signal s_ALUSel   : std_logic_vector(3 downto 0);
  signal s_SDMemWr  : std_logic_vector(0 downto 0);
  signal s_WBSel    : std_logic_vector(1 downto 0);
  signal s_SHALT    : std_logic_vector(0 downto 0);
  signal s_BR	    : std_logic_vector(0 downto 0); 
  signal s_MemRead  : std_logic_vector(0 downto 0);

begin

-- injecting zeros (NOPS)
  s_RS1 <= (others => '0') when i_FLUSH = '1' else i_RS1;
  s_RS2 <= (others => '0') when i_FLUSH = '1' else i_RS2;
  s_PC <= (others => '0') when i_FLUSH = '1' else i_PC;
  s_PCP4 <= (others => '0') when i_FLUSH = '1' else i_PCP4;
  s_ImmOut <= (others => '0') when i_FLUSH = '1' else i_ImmOut;
  s_RD <= (others => '0') when i_FLUSH = '1' else i_RD;
  s_INST <= (others => '0') when i_FLUSH = '1' else i_INST;
  
  s_SRegWr <= (others => '0') when i_FLUSH = '1' else i_SRegWr;
  s_BrUn <= (others => '0') when i_FLUSH = '1' else i_BrUn;
  s_Asel <= (others => '0') when i_FLUSH = '1' else i_Asel;
  s_Bsel <= (others => '0') when i_FLUSH = '1' else i_Bsel;
  s_funct3 <= (others => '0') when i_FLUSH = '1' else i_funct3;
  s_ALUSel <= (others => '0') when i_FLUSH = '1' else i_ALUSel;
  s_SDMemWr <= (others => '0') when i_FLUSH = '1' else i_SDMemWr;
  s_WBSel <= (others => '0') when i_FLUSH = '1' else i_WBSel;
  s_SHALT <= (others => '0') when i_FLUSH = '1' else i_SHALT;
  s_BR <= (others => '0') when i_FLUSH = '1' else i_BR;
  s_MemRead <= (others => '0') when i_FLUSH = '1' else i_MemRead;
  
  --regs for data flow
  RS1_REG: Reg_N
	port map(
		i_CLK => i_CLK,
		i_RST => i_RST,
		i_WE  => i_WE,
		i_D   => s_RS1, --rs1 value
		o_Q   => q_RS1  --output data
	);

  RS2_REG: Reg_N
	port map(
		i_CLK => i_CLK,
		i_RST => i_RST,
		i_WE  => i_WE,
		i_D   => s_RS2, --rs2 value
		o_Q   => q_RS2  --output data
	);

  PC_REG: Reg_N
	port map(
		i_CLK => i_CLK,
		i_RST => i_RST,
		i_WE  => i_WE,
		i_D   => s_PC, --pc value
		o_Q   => q_PC  --output data
	);

  PCP4_REG: Reg_N
	port map(
		i_CLK => i_CLK,
		i_RST => i_RST,
		i_WE  => i_WE,
		i_D   => s_PCP4, --pcp4 value
		o_Q   => q_PCP4  --output data
	);

  ImmOut_REG: Reg_N
	port map(
		i_CLK => i_CLK,
		i_RST => i_RST,
		i_WE  => i_WE,
		i_D   => s_ImmOut, --ImmOut value
		o_Q   => q_ImmOut  --output data
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
	
  INST_REG: Reg_N
	port map(
		i_CLK => i_CLK,
		i_RST => i_RST,
		i_WE  => i_WE,
		i_D   => s_INST,--inst value
		o_Q   => q_INST --output data
	);
  
	
  -- regs for control values
  SREGWR: Reg_N generic map(N => 1) port map(i_CLK => i_CLK,i_RST => i_RST,i_WE  => i_WE,i_D => s_SRegWr, o_Q => q_SRegWr);
  BRUN: Reg_N generic map(N => 1) port map(i_CLK => i_CLK,i_RST => i_RST,i_WE  => i_WE, i_D => s_BrUn, o_Q => q_BrUn);
  ASEL: Reg_N generic map(N => 1) port map(i_CLK => i_CLK,i_RST => i_RST,i_WE  => i_WE, i_D => s_Asel, o_Q => q_Asel);
  BSEL: Reg_N generic map(N => 1) port map(i_CLK => i_CLK,i_RST => i_RST,i_WE  => i_WE, i_D => s_Bsel, o_Q => q_Bsel);
  FUNCT3: Reg_N generic map(N => 3) port map(i_CLK => i_CLK,i_RST => i_RST,i_WE  => i_WE, i_D => s_funct3, o_Q => q_funct3);
  ALUSEL: Reg_N generic map(N => 4) port map(i_CLK => i_CLK,i_RST => i_RST,i_WE  => i_WE, i_D => s_ALUSel, o_Q => q_ALUSel);
  SDMEMWR: Reg_N generic map(N => 1) port map(i_CLK => i_CLK,i_RST => i_RST,i_WE  => i_WE, i_D => s_SDmemWr, o_Q => q_SDMemWr); 
  WBSEL: Reg_N generic map(N => 2) port map(i_CLK => i_CLK,i_RST => i_RST,i_WE  => i_WE, i_D => s_WBSel, o_Q => q_WBSel);
  SHALT: Reg_N generic map(N => 1) port map(i_CLK => i_CLK,i_RST => i_RST,i_WE  => i_WE, i_D => s_SHALT, o_Q => q_SHALT);
  BR: Reg_N generic map(N => 1) port map(i_CLK => i_CLK,i_RST => i_RST,i_WE  => i_WE, i_D => s_BR, o_Q => q_BR);
  MemRead_REG: Reg_N generic map(N => 1) port map(i_CLK => i_CLK, i_RST => i_RST, i_WE  => i_WE, i_D   => s_MemRead, o_Q => q_MemRead );
  RS1_ADDR_REG: Reg_N generic map(N => 5) port map(i_CLK=>i_CLK, i_RST=>i_RST, i_WE=>i_WE, i_D=>s_RS1_Addr, o_Q=>q_RS1_Addr);
  RS2_ADDR_REG: Reg_N generic map(N => 5) port map(i_CLK=>i_CLK, i_RST=>i_RST, i_WE=>i_WE, i_D=>s_RS2_Addr, o_Q=>q_RS2_Addr);
	
  
  --outputs of this pipeline stage
  o_RS1 <= q_RS1;
  o_RS2 <= q_RS2;
  o_PC <= q_PC;
  o_PCP4 <= q_PCP4;
  o_ImmOut <= q_ImmOut;
  o_RD <= q_RD;
  o_INST <= q_INST;
  
  o_SRegWr <= q_SRegWr(0);
  o_BrUn <= q_BrUn(0);
  o_Asel <= q_Asel(0);
  o_Bsel <= q_Bsel(0);
  o_funct3 <= q_funct3;
  o_ALUSel <= q_ALUSel;
  o_SDMemWr <= q_SDMemWr(0);
  o_WBSel <= q_WBSel;
  o_SHALT <= q_SHALT(0);
  o_BR <= q_BR(0);
	
end structure;
