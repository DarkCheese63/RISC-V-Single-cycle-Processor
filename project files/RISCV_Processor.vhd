-- RISCV_Processor.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains a RISCV_Processor  
-- implementation, integrated with IF/ID, ID/EX, EX/MEM, MEM/WB pipeline regs.
--
-- 11/12/2025 - integrated pipeline registers and fixed top-level wiring
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;


entity RISCV_Processor is
  generic(N : integer := 32; DATA_WIDTH : integer := 32; ADDR_WIDTH : integer := 10);
  port(iCLK            : in std_logic;
       iRST            : in std_logic;
       iInstLd         : in std_logic;
       iInstAddr       : in std_logic_vector(N-1 downto 0);
       iInstExt        : in std_logic_vector(N-1 downto 0);
       oALUOut         : out std_logic_vector(N-1 downto 0)); -- TODO: Hook this up to the output of the ALU. It is important for synthesis that you have this output that can effectively be impacted by all other components so they are not optimized away.

end  RISCV_Processor;


architecture structure of RISCV_Processor is

  -- Required data memory signals
  signal s_DMemWr       : std_logic; -- TODO: use this signal as the final active high data memory write enable signal
  signal s_DMemAddr     : std_logic_vector(N-1 downto 0); -- TODO: use this signal as the final data memory address input
  signal s_DMemData     : std_logic_vector(N-1 downto 0); -- TODO: use this signal as the final data memory data input
  signal s_DMemOut      : std_logic_vector(N-1 downto 0); -- TODO: use this signal as the data memory output
 
  -- Required register file signals 
  signal s_RegWr        : std_logic; -- TODO: use this signal as the final active high write enable input to the register file
  signal s_RegWrAddr    : std_logic_vector(4 downto 0); -- TODO: use this signal as the final destination register address input
  signal s_RegWrData    : std_logic_vector(N-1 downto 0); -- TODO: use this signal as the final data memory data input

  -- Required instruction memory signals
  signal s_IMemAddr     : std_logic_vector(N-1 downto 0); -- Do not assign this signal, assign to s_NextInstAddr instead
  signal s_NextInstAddr : std_logic_vector(N-1 downto 0); -- TODO: use this signal as your intended final instruction memory address input.
  signal s_Inst         : std_logic_vector(N-1 downto 0); -- TODO: use this signal as the instruction signal 

  -- Required halt signal -- for simulation
  signal s_Halt         : std_logic;  -- TODO: this signal indicates to the simulation that intended program execution has completed. (Opcode: 01 0100)

  -- Required overflow signal -- for overflow exception detection
  signal s_Ovfl         : std_logic;  -- TODO: this signal indicates an overflow exception would have been initiated

  component mem is
    generic(ADDR_WIDTH : integer;
            DATA_WIDTH : integer);
    port(
          clk          : in std_logic;
          addr         : in std_logic_vector((ADDR_WIDTH-1) downto 0);
          data         : in std_logic_vector((DATA_WIDTH-1) downto 0);
          we           : in std_logic := '1';
          q            : out std_logic_vector((DATA_WIDTH -1) downto 0));
    end component;

  -- TODO: You may add any additional signals or components your implementation requires below this comment
  -- control signals
  signal s_ALUSel : std_logic_vector(3 downto 0); --ALU control
  signal s_ASel   : std_logic;     		  --select Amux
  signal s_BSel   : std_logic; 			  --select Bmux
  signal s_ImmSel : std_logic_vector(2 downto 0); 	  --Type of ImmGen
  signal s_WBSel  : std_logic_vector(1 downto 0); 	  --mux3t1 selector
  signal s_BrUn   : std_logic;				-- unsinged/signed branch
  signal s_funct3 : std_logic_vector(2 downto 0); --funct3

  signal s_ALUOut : std_logic_vector(31 downto 0); --ALU output
  signal s_ALUOut_masked : std_logic_vector(N-1 downto 0); --helper for fetch logic

  signal s_Aout   : std_logic_vector(31 downto 0); --rs1 out
  signal s_Bout   : std_logic_vector(31 downto 0); --rs2 out

  signal s_ALUzero: std_logic; --zero from ALU
  signal s_Cout   : std_logic; --Carry out line / ovfl

  signal s_PCOut  : std_logic_vector(31 downto 0) := (others => '0'); -- Current PC from fetch
  signal s_ImmOut : std_logic_vector(31 downto 0); --imm out signal
  signal s_PCsrc  : std_logic_vector(1 downto 0); --PCsrc signal
  signal s_IMemInst : std_logic_vector(31 downto 0); --imem inst

  signal s_Amux   : std_logic_vector(31 downto 0); --Amux value
  signal s_Bmux   : std_logic_vector(31 downto 0); --Bmux value

  signal s_BranchCond : std_logic; --branch comp output
  signal s_BranchEn : std_logic; --branch control unit signal
  signal s_branch : std_logic; --gated branch for PCsrc
  
  signal s_LoadData_Ext : std_logic_vector(N-1 downto 0);

  --pipeline signals
  signal s_FLUSH : std_logic;

  signal s_PC_IF_ID : std_logic_vector(N-1 downto 0);
  signal s_PCP4_IF_ID : std_logic_vector(N-1 downto 0);
  signal s_INST_IF_ID : std_logic_vector(N-1 downto 0);
  signal s_IF_ID_Write : std_logic;
  signal s_PC_Write : std_logic;
  
  signal s_RegWr_ID : std_logic; --temp signal to carry reg wr en to idex pipeline to avoid multiple drivers
  signal s_DMemWr_ID : std_logic; --avoiding multiple drivers for synth

  signal s_Aout_ID_EX : std_logic_vector(N-1 downto 0);   
  signal s_Bout_ID_EX : std_logic_vector(N-1 downto 0);   
  signal s_PC_ID_EX : std_logic_vector(N-1 downto 0);    
  signal s_PCP4_ID_EX : std_logic_vector(N-1 downto 0);  
  signal s_ImmOut_ID_EX : std_logic_vector(N-1 downto 0); 
  signal s_RD_ID_EX : std_logic_vector(4 downto 0); -- rd (bits 11 downto 7)
  signal s_INST_ID_EX : std_logic_vector(N-1 downto 0);

  signal s_RegWr_ID_EX : std_logic;   
  signal s_BrUn_ID_EX : std_logic;     
  signal s_Asel_ID_EX : std_logic;
  signal s_Bsel_ID_EX : std_logic;     
  signal s_funct3_ID_EX : std_logic_vector(2 downto 0);   
  signal s_ALUSel_ID_EX : std_logic_vector(3 downto 0); 
  signal s_DMemWr_ID_EX : std_logic;  
  signal s_WBSel_ID_EX : std_logic_vector(1 downto 0);     
  signal s_HALT_ID_EX : std_logic;
  signal s_END : std_logic; --this is to replace the initial wire due to the toolflow being tied into s_Halt for termination, this prevents early termination and allows for termination in the WB stage	  
  signal s_BR_ID_EX: std_logic;	

  -- EX/MEM pipeline outputs
  signal s_ALUOut_EX_MEM : std_logic_vector(N-1 downto 0);
  signal s_ALUmasked_EX_MEM : std_logic_vector(N-1 downto 0);
  signal s_RS2_EX_MEM    : std_logic_vector(N-1 downto 0);
  signal s_RD_EX_MEM     : std_logic_vector(4 downto 0);
  signal s_PCP4_EX_MEM   : std_logic_vector(N-1 downto 0);
  signal s_INST_EX_MEM : std_logic_vector(N-1 downto 0);
  signal s_ImmOut_EX_MEM : std_logic_vector(N-1 downto 0);
  signal s_PCsrc_EX_MEM : std_logic_vector(1 downto 0);
  signal s_PC_EX_MEM	: std_logic_vector(N-1 downto 0);

  signal s_RegWr_EX_MEM  : std_logic;
  signal s_DMemWr_EX_MEM : std_logic;
  signal s_WBSel_EX_MEM  : std_logic_vector(1 downto 0);
  signal s_HALT_EX_MEM   : std_logic;

  -- MEM/WB pipeline outputs
  signal s_RegWr_MEM_WB  : std_logic;
  signal s_WBSel_MEM_WB  : std_logic_vector(1 downto 0);
  signal s_HALT_MEM_WB   : std_logic;
  signal s_INST_MEM_WB : std_logic_vector(N-1 downto 0);

  signal s_ALUOut_MEM_WB : std_logic_vector(N-1 downto 0);
  signal s_PCP4_MEM_WB   : std_logic_vector(N-1 downto 0);
  signal s_SDMemOut_MEM_WB : std_logic_vector(N-1 downto 0);
  signal s_ImmOut_MEM_WB   : std_logic_vector(N-1 downto 0);
  signal s_RD_MEM_WB     : std_logic_vector(4 downto 0);
  
  signal s_MemRead        : std_logic; -- Calculated in ID stage
  signal s_MemRead_ID_EX  : std_logic; -- Output of ID/EX Register
  signal s_RS1_Addr_ID_EX : std_logic_vector(4 downto 0); -- Saved RS1 Addr
  signal s_RS2_Addr_ID_EX : std_logic_vector(4 downto 0); -- Saved RS2 Add
  
  -- FORWARDING SIGNALS
  signal s_ForwardA    : std_logic_vector(1 downto 0); -- Selector for Input A
  signal s_ForwardB    : std_logic_vector(1 downto 0); -- Selector for Input B

  signal s_Forwarded_A   : std_logic_vector(31 downto 0); -- The final value entering ALU Input A
  signal s_Forwarded_B   : std_logic_vector(31 downto 0);
  
  
  -- IF/ID flush signal
  signal s_IF_ID_Flush : std_logic;
  -- ID/EX flush signal
  signal s_ID_EX_Flush : std_logic;
  -- branch taken
  signal s_Branch_taken : std_logic;
  signal s_Forwarded_RS1 : std_logic_vector(31 downto 0);
  signal s_Forwarded_RS2 : std_logic_vector(31 downto 0);

  component controlUnit is 
    port(
        c_IN     : in  std_logic_vector(31 downto 0);
        ImmSel   : out std_logic_vector(2 downto 0);
        s_RegWr  : out std_logic;
        BrUn     : out std_logic;
        Asel     : out std_logic;
        Bsel     : out std_logic;
	o_funct3 : out std_logic_vector(2 downto 0);
        ALUSel   : out std_logic_vector(3 downto 0);
        s_DMemWr : out std_logic;
        WBSel    : out std_logic_vector(1 downto 0);
	s_HALT	 : out std_logic;
	BR	 : out std_logic 
    );
  end component;
  

  component ALU is 
    port(
	A	 : in std_logic_vector(31 downto 0); -- first data input
	B	 : in std_logic_vector(31 downto 0); -- second data input
	ALUCtrl	 : in std_logic_vector(3 downto 0); -- output of the alu control
	Result	 : out std_logic_vector(31 downto 0);
	zero	 : out std_logic;
	Cout	 : out std_logic
	);
  end component;

  component branch_comp is 
    port(
	i_A : in std_logic_vector(31 downto 0);
	i_B : in std_logic_vector(31 downto 0);
	i_funct3 : in std_logic_vector(2 downto 0);
	i_BrUn : in std_logic;
	o_Branch : out std_logic
        );
  end component;

  component FetchLogic is
    port(
	rst      : in std_logic;
	clk      : in std_logic;
	imm      : in std_logic_vector(31 downto 0); -- immediate value branch/jump
	ALUo     : in std_logic_vector(31 downto 0); -- jalr target from alu 
	PCsrc    : in std_logic_vector(1 downto 0); -- pc select 00 = pc+4, 01 = branch, 10 = jump, 11 = jalr
	jump_target : in std_logic_vector(31 downto 0);
	pc_branch : in std_logic_vector(31 downto 0);
	PC_Write : in std_logic; -- 0=enable 1=stall
	PCP4     : out std_logic_vector(31 downto 0); -- PC + 4 output
	currPC   : out std_logic_vector(31 downto 0) -- current pc value
	);
  end component;

  component RegisterFile is 
    port(
	i_RD1    : in std_logic_vector(4 downto 0);
	i_RS1    : in std_logic_vector(4 downto 0);
	i_RS2    : in std_logic_vector(4 downto 0);
	i_RST    : in STD_LOGIC;
	i_CLK    : in STD_LOGIC;
	wr_EN    : in STD_LOGIC;
	wr_DATA  : in std_logic_vector(31 downto 0);
	o_RS1    : out std_logic_vector(31 downto 0);
	o_RS2    : out std_logic_vector(31 downto 0)
	);
  end component;


  component ImmGen is
    port(
	i_ImmSel   : in std_logic_vector(2 downto 0);
        i_ImmType : in std_logic_vector(31 downto 0);
	o_Imm    : out std_logic_vector(31 downto 0)
	);
  end component;

  component mux2t1_N is
    port(i_S          : in std_logic;
       i_D0         : in std_logic_vector(N-1 downto 0);
       i_D1         : in std_logic_vector(N-1 downto 0);
       o_O          : out std_logic_vector(N-1 downto 0)
	);
 end component;

  component mux4t1_N is 
	generic(N : integer := 32);
	port(		
		i_S  : in  std_logic_vector(1 downto 0);  -- 2-bit select
		i_D0 : in  std_logic_vector(N-1 downto 0); --dmemout
		i_D1 : in  std_logic_vector(N-1 downto 0); --aluout
		i_D2 : in  std_logic_vector(N-1 downto 0); --nextinstadd
		i_D3 : in  std_logic_vector(N-1 downto 0); --immval
		o_O  : out std_logic_vector(N-1 downto 0)
	);
  end component;

  component Reg_IF_ID is 
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
  end component;

  component Reg_ID_EX is 
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
		o_RS1_Addr : out std_logic_vector(4 downto 0);
        	o_RS2_Addr : out std_logic_vector(4 downto 0);
        	o_MemRead  : out std_logic_vector(0 downto 0)
	);
  end component;

  component Reg_EX_MEM is 
	generic(N : integer := 32);
	port(
		i_CLK : in STD_LOGIC; -- clock input - 1 bit	
		i_RST : in STD_LOGIC; -- reset input - 1 bit
		i_WE  : in STD_LOGIC;
		
		--control signals from previous stage ID/EX
		i_SRegWr   : in std_logic_vector(0 downto 0); 
		i_SDMemWr  : in std_logic_vector(0 downto 0);
		i_WBSel    : in std_logic_vector(1 downto 0);
		i_SHALT	   : in std_logic_vector(0 downto 0);
		i_INST   : in std_logic_vector(N-1 downto 0);
		i_ImmOut : in std_logic_vector(N-1 downto 0); 
		i_PCsrc	   : in std_logic_vector(1 downto 0);
		i_ALUmasked : in std_logic_vector(N-1 downto 0);
		i_PC	: in std_logic_vector(N-1 downto 0);


		--dataflow values
		i_ALU : in std_logic_vector(N-1 downto 0); 
		i_RS2    : in std_logic_vector(N-1 downto 0);
		i_RD	 : in std_logic_vector(4 downto 0);
		i_PCP4   : in std_logic_vector(N-1 downto 0);
		
		--outputs
		o_SRegWr   : out std_logic; 
		o_SDMemWr  : out std_logic;
		o_WBSel    : out std_logic_vector(1 downto 0);
		o_SHALT	   : out std_logic;
		o_INST   : out std_logic_vector(N-1 downto 0);
		o_ImmOut : out std_logic_vector(N-1 downto 0);
		o_PCsrc : out std_logic_vector(1 downto 0);
		o_ALUmasked : out std_logic_vector(N-1 downto 0);
		o_PC	: out std_logic_vector(N-1 downto 0);

		o_ALU    : out std_logic_vector(N-1 downto 0); --outputs of A and B from reg file and immgen regs
		o_RS2    : out std_logic_vector(N-1 downto 0);
		o_RD     : out std_logic_vector(4 downto 0);
		o_PCP4   : out std_logic_vector(N-1 downto 0)
	);
  end component;

  component Reg_MEM_WB is 
	generic(N : integer := 32);
	port(
		i_CLK : in STD_LOGIC; -- clock input - 1 bit	
		i_RST : in STD_LOGIC; -- reset input - 1 bit
		i_WE  : in STD_LOGIC;
		
		--control signals from previous stage EX/MEM
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
		o_ImmOut : out std_logic_vector(N-1 downto 0);
		o_RD     : out std_logic_vector(4 downto 0)
	);
end component;

-- Hardware Detection Unit
component HDU is 
	port(
		i_ID_EX_MemRead	: in std_logic; -- checks if instruction is a load
		i_ID_EX_RD	: in std_logic_vector(4 downto 0);
		i_IF_ID_RS1	: in std_logic_vector(4 downto 0);
		i_IF_ID_RS2	: in std_logic_vector(4 downto 0);
		i_Branch_taken	: in std_logic;
		
		o_PC_Write	: out std_logic; -- 1 = enable 0 = stall
		o_IF_ID_Write	: out std_logic; -- 1 = enable 0 = stall
		o_IF_ID_Flush	: out std_logic; -- 1 = flush the register
		o_ID_EX_Flush	: out std_logic -- 1 = flush the register
	);
end component;

-- Forwarding Unit
component Forwarding_Unit is
	port(
		-- current instruction from ID/EX
		i_ID_EX_RS1 : in std_logic_vector(4 downto 0);
		i_ID_EX_RS2 : in std_logic_vector(4 downto 0);
		-- previous instruction from EX/MEM
		i_EX_MEM_RD : in std_logic_vector(4 downto 0);
		i_EX_MEM_RegWr : in std_logic;
		-- even more previous instruction from MEM/WB (2 cycles ahead)
		i_MEM_WB_RD : in std_logic_vector(4 downto 0);
		i_MEM_WB_RegWr : in std_logic;
		-- outputs
		o_ForwardA : out std_logic_vector(1 downto 0);
		o_ForwardB : out std_logic_vector(1 downto 0)
	);
end component;

  
begin

  -- TODO: This is required to be your final input to your instruction memory. This provides a feasible method to externally load the memory module which means that the synthesis tool must assume it knows nothing about the values stored in the instruction memory. If this is not included, much, if not all of the design is optimized out because the synthesis tool will believe the memory to be all zeros.
  with iInstLd select
    s_IMemAddr <= s_PCOut when '0',
      iInstAddr when others;
  

  -- TODO: Ensure that s_Halt is connected to an output control signal produced from decoding the Halt instruction (Opcode: 01 0100)
  -- TODO: Ensure that s_Ovfl is connected to the overflow output of your ALU

  -- TODO: Implement the rest of your processor below this comment! 

  FL: FetchLogic
	port map(
	rst  => iRST,
	clk => iCLK,
	imm  => s_ImmOut_EX_MEM,
	ALUo => s_ALUmasked_EX_MEM,
	PCsrc => s_PCsrc_EX_MEM,
	jump_target => s_ALUOut_EX_MEM,
	pc_branch => s_PC_EX_MEM,
	PC_Write => s_PC_Write,
	PCP4 => s_NextInstAddr,
	currPC => s_PCOut
	);
	
  IMem: mem
    generic map(ADDR_WIDTH => ADDR_WIDTH,
                DATA_WIDTH => N)
    port map(clk  => iCLK,
             addr => s_IMemAddr(ADDR_WIDTH+1 downto 2),
             data => iInstExt,
             we   => iInstLd,
             q    => s_Inst);

  -- IF/ID pipeline register: flush from s_FLUSH, always write (i_WE => '1')
  IF_ID: Reg_IF_ID
    generic map(N => N)
	port map(
		i_CLK => iCLK,
		i_RST => iRST,
		i_WE  => s_IF_ID_Write,
		i_FLUSH => s_IF_ID_Flush,
		--will use flush with hardware
		i_PC => s_PCOut,
		i_PCP4 => s_NextInstAddr,
		i_INST => s_Inst,
		o_PC => s_PC_IF_ID,
		o_PCP4 => s_PCP4_IF_ID,
		o_INST => s_INST_IF_ID
	);

  CU: controlUnit
	port map(
	c_IN => s_INST_IF_ID,
        ImmSel => s_ImmSel,
        s_RegWr => s_RegWr_ID,
        BrUn => s_BrUn,
        Asel => s_Asel,
        Bsel => s_Bsel,
	o_funct3 => s_funct3,
        ALUSel => s_ALUSel,
        s_DMemWr => s_DMemWr_ID, 
        WBSel => s_WBSel,
	s_HALT => s_END,
	BR => s_BranchEn
	);
  s_MemRead <= '1' when s_WBSel = "00" else '0';

  RF: RegisterFile
	port map(
		i_RD1 => s_RegWrAddr,
		i_RS1 => s_INST_IF_ID(19 downto 15),
		i_RS2 => s_INST_IF_ID(24 downto 20),
		i_RST => iRST,
		i_CLK => not iCLK,
		wr_EN => s_RegWr,
		wr_DATA => s_RegWrData,
		o_RS1 => s_Aout,
		o_RS2 => s_Bout
	);

  IG: ImmGen
	port map(
	i_ImmSel => s_ImmSel,
        i_ImmType => s_INST_IF_ID,
	o_Imm => s_ImmOut
	);
	
  HD: HDU
  	port map(
  		i_ID_EX_MemRead => s_MemRead_ID_EX,
  		i_ID_EX_RD => s_RD_ID_EX,
  		i_IF_ID_RS1 => s_INST_IF_ID(19 downto 15),
  		i_IF_ID_RS2 => s_INST_IF_ID(24 downto 20),
  		i_Branch_taken => s_Branch_taken,
  		
  		o_PC_Write => s_PC_Write,
  		o_IF_ID_Write => s_IF_ID_Write,
  		o_IF_ID_Flush => s_IF_ID_Flush,
  		o_ID_EX_Flush => s_ID_EX_Flush
  	); 

  -- ID/EX pipeline register:
  ID_EX: Reg_ID_EX
     generic map(N => N)
	port map(
		i_CLK => iCLK,
		i_RST => iRST,
		i_WE => '1',
		i_FLUSH => s_ID_EX_Flush,
		--will use s_FLUSH when flushing/stalling on hardware

		-- Signals from control unit
		i_SRegWr => (others => s_RegWr_ID),
		i_BrUn => (others => s_BrUn),
		i_Asel => (others => s_Asel),
		i_Bsel => (others => s_Bsel),
		i_funct3 => s_funct3,
		i_ALUSel => s_ALUSel,
		i_SDMemWr => (others => s_DMemWr_ID),
		i_WBSel => s_WBSel,
		i_SHALT => (others => s_END),
		i_BR => (others => s_BranchEn),
		i_MemRead(0) => s_MemRead,
		

		-- dataflow values
		i_RS1 => s_Aout,
		i_RS2 => s_Bout,
		i_PC => s_PC_IF_ID,
		i_PCP4 => s_PCP4_IF_ID,
		i_ImmOut => s_ImmOut,
		i_RD => s_INST_IF_ID(11 downto 7),
		i_INST => s_INST_IF_ID,
		i_RS1_Addr => s_INST_IF_ID(19 downto 15), 
        	i_RS2_Addr => s_INST_IF_ID(24 downto 20),

		o_RS1 => s_Aout_ID_EX,
		o_RS2 => s_Bout_ID_EX,
		o_PC => s_PC_ID_EX,
		o_PCP4 => s_PCP4_ID_EX,
		o_ImmOut => s_ImmOut_ID_EX,
		o_RD => s_RD_ID_EX,
		o_INST => s_INST_ID_EX,
		o_RS1_Addr => s_RS1_Addr_ID_EX,
        	o_RS2_Addr => s_RS2_Addr_ID_EX,

		o_SRegWr => s_RegWr_ID_EX,
		o_BrUn => s_BrUn_ID_EX,
		o_Asel => s_Asel_ID_EX,
		o_Bsel => s_Bsel_ID_EX,
		o_funct3 => s_funct3_ID_EX,
		o_ALUSel => s_ALUSel_ID_EX,
		o_SDMemWr => s_DMemWr_ID_EX,
		o_WBSel => s_WBSel_ID_EX,
		o_SHALT => s_HALT_ID_EX,
		o_BR => s_BR_ID_EX,
		o_MemRead(0) => s_MemRead_ID_EX
	);

  -- Branch compare in EX stage: uses ID/EX values
  bc: branch_comp
	port map(
		i_A => s_Aout_ID_EX,
		i_B => s_Bout_ID_EX,
		i_funct3 => s_funct3_ID_EX,
		i_BrUn => s_BrUn_ID_EX,
		o_Branch => s_BranchCond
        );
  -- branch
  s_branch <= s_BranchCond and s_BR_ID_EX;
  
  -- forwarding mux for rs1 or Amux
  with s_ForwardA select
    s_Forwarded_RS1 <= s_Aout_ID_EX      when "00", -- Original (ID/EX)
                       s_ALUOut_EX_MEM   when "10", -- Forward from EX
                       s_RegWrData       when "01", -- Forward from WB
                       s_Aout_ID_EX      when others;

-- forwarding mux for rs2 or Bmux
  with s_ForwardB select
    s_Forwarded_RS2 <= s_Bout_ID_EX      when "00", -- Original (ID/EX)
                       s_ALUOut_EX_MEM   when "10", -- Forward from EX
                       s_RegWrData       when "01", -- Forward from WB
                       s_Bout_ID_EX      when others;
  
  -- ALU operand muxes and ALU
  AMUX: mux2t1_N
	port map(
	i_S => s_Asel_ID_EX,
        i_D0 => s_Forwarded_RS1,
        i_D1 => s_PC_ID_EX,
        o_O => s_Forwarded_A
	);

  BMUX: mux2t1_N
	port map(
	i_S => s_Bsel_ID_EX,
        i_D0 => s_Forwarded_RS2,
        i_D1 => s_ImmOut_ID_EX,
        o_O => s_Forwarded_B
	);

  Arith_Logic_Unit: ALU
        port map(
		A => s_Forwarded_A,
		B => s_Forwarded_B,
		ALUCtrl => s_ALUSel_ID_EX,
		Result => s_ALUOut,
		zero => s_ALUzero,
		Cout => s_Ovfl
	);
	 s_Ovfl <= '0';
	   -- output ALU for toolflow
  	oALUOut <= s_ALUOut;
  	
  	
  -- PC select logic (jal/jalr/branch)
  process (s_Branch, s_INST_ID_EX)
  begin
  	s_PCsrc <= "00";
  	case s_INST_ID_EX(6 downto 0) is
  		when "1101111" => -- jal
  			s_PCsrc <= "10";
  		when "1100111" => -- jalr
  			s_PCsrc <= "11";
  		when "1100011" => -- branch
  			if s_branch = '1' then
  				s_PCsrc <= "01";
  			else
  				s_PCsrc <= "00";
  			end if;
  		when others =>
  			s_PCsrc <= "00";
  	end case;
  end process;
  
    -- flush the earlier stages when a branch is taken in EX, implemented in hardware
 s_Branch_taken <= '1' when s_PCsrc = "10" else
  	     '1' when s_PCsrc = "11" else
  	     '0';


	-- Forwarding Unit
  FU: Forwarding_Unit
  	port map(
  		i_ID_EX_RS1 => s_Aout_ID_EX,
  		i_ID_EX_RS2 => s_Bout_ID_EX,
  		
  		i_EX_MEM_RD => s_RD_EX_MEM,
  		i_EX_MEM_RegWr => s_RegWr_EX_MEM,
  		
  		i_MEM_WB_RD => s_RD_MEM_WB,
  		i_MEM_WB_RegWr => s_RegWr_MEM_WB,
  		
  		o_ForwardA => s_ForwardA,
  		o_ForwardB => s_ForwardB
  	);


	


  -- jalr mask special-case: if instruction is jalr (1100111), mask bit0
  s_ALUOut_masked <= s_ALUOut when s_INST_ID_EX(6 downto 0) /= "1100111" else
		(s_ALUOut(31 downto 1) & '0');

  -- EX/MEM pipeline register: 
  EX_MEM: Reg_EX_MEM
    generic map(N => N)
	port map(
		i_CLK => iCLK,
		i_RST => iRST,
		i_WE => '1',

		-- control signals from ID/EX
		i_SRegWr => (others => s_RegWr_ID_EX),
		i_SDMemWr => (others => s_DMemWr_ID_EX),
		i_WBSel => s_WBSel_ID_EX,
		i_SHALT => (others => s_HALT_ID_EX),
		i_PCsrc => s_PCsrc,
		i_PC => s_PC_ID_EX,


		-- dataflow values
		i_ALU => s_ALUOut,
		i_ALUmasked => s_ALUout_masked,
		i_RS2 => s_Bout_ID_EX,
		i_RD => s_RD_ID_EX,
		i_PCP4 => s_PCP4_ID_EX,
		i_INST => s_INST_ID_EX,
		i_ImmOut => s_ImmOut_ID_EX,

		-- outputs (to MEM stage)
		o_SRegWr => s_RegWr_EX_MEM,
		o_SDMemWr => s_DMemWr_EX_MEM,
		o_WBSel => s_WBSel_EX_MEM,
		o_SHALT => s_HALT_EX_MEM,
		o_INST => s_INST_EX_MEM,
		o_ImmOut => s_ImmOut_EX_MEM,
		o_PCsrc => s_PCsrc_EX_MEM,
		o_ALUmasked => s_ALUmasked_EX_MEM,
		o_PC => s_PC_EX_MEM,

		o_ALU => s_ALUOut_EX_MEM,
		o_RS2 => s_RS2_EX_MEM,
		o_RD => s_RD_EX_MEM,
		o_PCP4 => s_PCP4_EX_MEM
	);
	
	
  -- Drive data memory address/data/we from EX/MEM pipeline outputs
  s_DMemAddr <= s_ALUOut_EX_MEM; --ALUout is DMem Addr
  s_DMemData <= s_RS2_EX_MEM; --rs2 is DMem data
  s_DMemWr <= s_DMemWr_EX_MEM; -- write enable for data memory (from EX/MEM)

  DMem: mem
    generic map(ADDR_WIDTH => ADDR_WIDTH,
                DATA_WIDTH => N)
    port map(clk  => iCLK,
             addr => s_DMemAddr(11 downto 2),
             data => s_DMemData,
             we   => s_DMemWr,
             q    => s_DMemOut);

  -- MEM/WB pipeline register: 
  MEM_WB: Reg_MEM_WB
    generic map(N => N)
	port map(
		i_CLK => iCLK,
		i_RST => iRST,
		i_WE => '1',

		i_SRegWr => (others => s_RegWr_EX_MEM),
		i_WBSel => s_WBSel_EX_MEM,
		i_SHALT => (others => s_HALT_EX_MEM),

		-- dataflow values from MEM stage
		i_ALU => s_ALUOut_EX_MEM,
		i_PCP4 => s_PCP4_EX_MEM,
		i_SDMemOut => s_DMemOut,
		i_ImmOut => s_ImmOut_EX_MEM, 
		i_RD => s_RD_EX_MEM,
		i_INST => s_INST_EX_MEM,

		-- outputs
		o_SRegWr => s_RegWr_MEM_WB,
		o_WBSel => s_WBSel_MEM_WB,
		o_SHALT => s_HALT_MEM_WB,
		o_INST => s_INST_MEM_WB,

		o_ALU => s_ALUOut_MEM_WB,
		o_PCP4 => s_PCP4_MEM_WB,
		o_SDMemOut => s_SDMemOut_MEM_WB,
		o_ImmOut => s_ImmOut_MEM_WB,
		o_RD => s_RD_MEM_WB
	);
	
  -- Load data extension logic (operating on MEM stage data)
  process(s_SDMemOut_MEM_WB, s_ALUOut_MEM_WB, s_INST_MEM_WB)
    variable v_addr_bits : std_logic_vector(1 downto 0);
  begin
  
    v_addr_bits := s_ALUOut_MEM_WB(1 downto 0); -- Lower 2 bits of the address (use ALU result from MEM/WB)
    
    if (s_INST_MEM_WB(6 downto 0) = "0000011") then 
      -- If it is a load then check the funct3 bits
      case s_INST_MEM_WB(14 downto 12) is 
        
        -- lb (sign-extend byte)
        when "000" => 
          case v_addr_bits is
            when "00" => s_LoadData_Ext <= (31 downto 8 => s_SDMemOut_MEM_WB(7)) & s_SDMemOut_MEM_WB(7 downto 0);
            when "01" => s_LoadData_Ext <= (31 downto 8 => s_SDMemOut_MEM_WB(15)) & s_SDMemOut_MEM_WB(15 downto 8);
            when "10" => s_LoadData_Ext <= (31 downto 8 => s_SDMemOut_MEM_WB(23)) & s_SDMemOut_MEM_WB(23 downto 16);
            when others => s_LoadData_Ext <= (31 downto 8 => s_SDMemOut_MEM_WB(31)) & s_SDMemOut_MEM_WB(31 downto 24);
          end case;
          
        -- lh (sign-extend halfword)
        when "001" => 
          case v_addr_bits(1) is
            when '0' => s_LoadData_Ext <= (31 downto 16 => s_SDMemOut_MEM_WB(15)) & s_SDMemOut_MEM_WB(15 downto 0);
            when others => s_LoadData_Ext <= (31 downto 16 => s_SDMemOut_MEM_WB(31)) & s_SDMemOut_MEM_WB(31 downto 16);
          end case;
          
        -- lw (load word)
        when "010" => 
          s_LoadData_Ext <= s_SDMemOut_MEM_WB;
          
        -- lbu (zero-extend byte)
        when "100" => 
          case v_addr_bits is
            when "00" => s_LoadData_Ext <= x"000000" & s_SDMemOut_MEM_WB(7 downto 0);
            when "01" => s_LoadData_Ext <= x"000000" & s_SDMemOut_MEM_WB(15 downto 8);
            when "10" => s_LoadData_Ext <= x"000000" & s_SDMemOut_MEM_WB(23 downto 16);
            when others => s_LoadData_Ext <= x"000000" & s_SDMemOut_MEM_WB(31 downto 24);
          end case;
          
        -- lhu (zero-extend halfword)
        when "101" => 
          case v_addr_bits(1) is
            when '0' => s_LoadData_Ext <= x"0000" & s_SDMemOut_MEM_WB(15 downto 0);
            when others => s_LoadData_Ext <= x"0000" & s_SDMemOut_MEM_WB(31 downto 16);
          end case;
          
        -- Default for any other funct3 
        when others => 
          s_LoadData_Ext <= s_SDMemOut_MEM_WB;
      end case;
      
    else 
        s_LoadData_Ext <= (others => '0');
    end if;
  end process;

  -- Writeback data mux (use MEM/WB stage outputs)
  WRDATAMUX: mux4t1_N
	port map(
		i_S => s_WBSel_MEM_WB,
		i_D0 => s_LoadData_Ext,	-- load-extended data from DMem (computed below)
		i_D1 => s_ALUOut_MEM_WB,	-- ALU result
		i_D2 => s_PCP4_MEM_WB,	-- PCP4 (for jal)
		i_D3 => s_ImmOut_MEM_WB,	-- immediate 
		o_O => s_RegWrData --feeds into reg file data
	);
	s_RegWrAddr <= s_RD_MEM_WB;
	s_RegWr <= s_RegWr_MEM_WB;


  --halt in wb stage
  s_Halt <= s_HALT_MEM_WB;

  
end structure;
