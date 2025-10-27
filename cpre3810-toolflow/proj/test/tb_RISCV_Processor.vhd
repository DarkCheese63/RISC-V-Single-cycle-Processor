library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_RISCV_Processor is
end tb_RISCV_Processor;

architecture sim of tb_RISCV_Processor is
  component RISCV_Processor is
  generic(N : integer := 32; DATA_WIDTH : integer := 32; ADDR_WIDTH : integer := 10);
  port(iCLK            : in std_logic;
       iRST            : in std_logic;
       iInstLd         : in std_logic;
       iInstAddr       : in std_logic_vector(N-1 downto 0);
       iInstExt        : in std_logic_vector(N-1 downto 0);
       oALUOut         : out std_logic_vector(N-1 downto 0)); -- TODO: Hook this up to the output of the ALU. It is important for synthesis that you have this output that can effectively be impacted by all other components so they are not optimized away.

  end component;


  -- DUT signals
	signal s_iCLK            : std_logic := '0';
       signal s_iRST            : std_logic;
       signal s_iInstLd         : std_logic;
       signal s_iInstAddr       : std_logic_vector(31 downto 0);
       signal s_iInstExt        : std_logic_vector(31 downto 0);
	signal s_ALUOut : std_logic_vector(31 downto 0);
begin

  -- Instantiate DUT
  uut: RISCV_Processor
    port map(
      iCLK => s_iCLK,
	iRST => s_iRST,
	iInstLd => s_iInstLd,
	iInstAddr => s_iInstAddr,
	iInstExt => s_iInstExt,
	oALUout => s_ALUOut
    );

  -- Clock stim
  s_iCLK <= not s_iCLK after 100 ns;

  process
  begin

    s_iRST <= '1';
    wait for 100 ns;
    s_iRST <= '0';
    wait for 100 ns;
	-- testing addi
	s_iInstLd <= '1';
	s_iInstAddr <= (others => '0');
	s_iInstExt <= x"00500093";
	wait for 100 ns;
	
	s_iInstLd <= '0';
	wait for 200 ns;

    wait;
  end process;

end sim;
