-------------------------------------------------------------------------
-- Matthew Estes
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- RISCVdatapath.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: this file is the structural implementation of a riscv datapath
--              
-- 09/18/2025
-------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

entity RISCVdatapath is 
	port(
		i_CLK      : in STD_LOGIC;
		i_RST      : in STD_LOGIC;
		rs1_addr   : in std_logic_vector(4 downto 0);  -- Source register 1
		rs2_addr   : in std_logic_vector(4 downto 0);  -- Source register 2
		rd_addr    : in std_logic_vector(4 downto 0);  -- Destination register
		imm        : in std_logic_vector(31 downto 0); -- Immediate input
		Add_sub   : in STD_LOGIC;                    -- ALU controls
		ALUsrc     : in STD_LOGIC;                    -- Selects between RS2 and imm
		wr_EN      : in STD_LOGIC;                    -- Write enable
		ALU_result : out std_logic_vector(31 downto 0)
	);
end RISCVdatapath;

architecture structure of RISCVdatapath is
	component RegisterFile 
		port(
			i_RD1   : in std_logic_vector(4 downto 0);
			i_RS1   : in std_logic_vector(4 downto 0);
			i_RS2   : in std_logic_vector(4 downto 0);
			i_RST   : in STD_LOGIC;
			i_CLK   : in STD_LOGIC;
			wr_EN   : in STD_LOGIC;
			wr_DATA : in std_logic_vector(31 downto 0);
			o_RS1   : out std_logic_vector(31 downto 0);
			o_RS2   : out std_logic_vector(31 downto 0)
		);
	end component;
	
	component nAdd_Sub 
		generic(N : integer := 16);
		port(
			i_A, i_B : in std_logic_vector(N-1 downto 0);
			nAdd_sub : in STD_LOGIC;
			Sum : out std_logic_vector(N-1 downto 0);
			Cout : out STD_LOGIC
		);
	end component;
	
	component mux2t1_N
		generic(N : integer := 16);
		port(i_S          : in std_logic;
		   i_D0         : in std_logic_vector(N-1 downto 0);
		   i_D1         : in std_logic_vector(N-1 downto 0);
		   o_O          : out std_logic_vector(N-1 downto 0)
		);
	end component;
	
	signal RS1      : std_logic_vector(31 downto 0);
	signal RS2      : std_logic_vector(31 downto 0);
	signal ALU_out  : std_logic_vector(31 downto 0);
	signal Cout     : std_logic;  
	signal mux_out  : std_logic_vector(31 downto 0);
	
	begin 
		MUX: mux2t1_N 
			generic map (N => 32)
			port map(
				i_S  => ALUsrc,
				i_D0 => RS2,
				i_D1 => imm,
				o_O  => mux_out 
			);
	
		ALU: nAdd_Sub
			generic map (N => 32)
			port map(
				i_A      => RS1,
				i_B      => mux_out,
				nAdd_sub => Add_sub,
				Sum      => ALU_out,
				Cout     => Cout
			);
		
		
		regFile: RegisterFile
			port map(
				i_RD1    => rd_addr,   
				i_RS1    => rs1_addr,
				i_RS2    => rs2_addr,
				i_RST    => i_RST,
				i_CLK    => i_CLK,
				wr_EN    => wr_EN,
				wr_DATA  => ALU_out,   
				o_RS1    => RS1,
				o_RS2    => RS2
			);
		ALU_result <= ALU_out;
end structure;
