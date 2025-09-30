-------------------------------------------------------------------------
-- Luke Olsen
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------

-- tb_reg_file.vhd
-------------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_reg_file is
  generic(gCLK_HPER : time := 100 ns; N : integer := 32);
end tb_reg_file;

architecture behavior of tb_reg_file is
  
  -- Calculate the clock period as twice the half-period
  constant cCLK_PER  : time := gCLK_HPER * 2;


  component reg_file
    generic(N : integer := 32);
    port(i_CLK          : in std_logic;
       i_RST          : in std_logic;
       i_WE           : in std_logic;
       i_WADDR	      : in std_logic_vector(4 downto 0); --write address
       i_WDATA 	      : in std_logic_vector(N-1 downto 0); --write data
       i_RADDR1	      : in std_logic_vector(4 downto 0); -- rs1
       i_RADDR2	      : in std_logic_vector(4 downto 0); -- rs2
       o_RDATA1	      : out std_logic_vector(N-1 downto 0);
       o_RDATA2	      : out std_logic_vector(N-1 downto 0));
  end component;

  -- Temporary signals to connect to the dff component.
       signal s_CLK          :  std_logic := '0';
       signal s_RST          :  std_logic := '1';
       signal s_WE           :  std_logic := '0';
       signal s_WADDR	     :  std_logic_vector(4 downto 0) := (others => '0'); --write address
       signal s_WDATA 	     :  std_logic_vector(N-1 downto 0) := (others => '0'); --write data
       signal s_RADDR1	     :  std_logic_vector(4 downto 0) := (others => '0'); -- rs1
       signal s_RADDR2	     :  std_logic_vector(4 downto 0) := (others => '0'); -- rs2
       signal s_RDATA1	     :  std_logic_vector(N-1 downto 0);
       signal s_RDATA2	     :  std_logic_vector(N-1 downto 0);

begin

  DUT: reg_file
	generic map(N => N)
  	port map(i_CLK => s_CLK, 
           i_RST => s_RST,
           i_WE  => s_WE,
           i_WADDR  => s_WADDR,
           i_WDATA  => s_WDATA,
	   i_RADDR1 => s_RADDR1,
	   i_RADDR2 => s_RADDR2,
	   o_RDATA1 => s_RDATA1,
	   o_RDATA2 => s_RDATA2);

  -- This process sets the clock value (low for gCLK_HPER, then high
  -- for gCLK_HPER). Absent a "wait" command, processes restart 
  -- at the beginning once they have reached the final statement.
  P_CLK: process
  begin
    s_CLK <= '0';
    wait for gCLK_HPER;
    s_CLK <= '1';
    wait for gCLK_HPER;
  end process;
  
  -- Testbench process  
  P_TB: process
  begin

	s_RST <= '1';
	wait for 100 ns;
	s_RST <= '0';

	-- writing to register 5 and reading from register 5
	s_WE <= '1';
	s_WADDR <= std_logic_vector(to_unsigned(5,5));
	s_WDATA <= x"FEEEEEED";
	wait until rising_edge(s_CLK);

	s_WE <= '0';
	wait until rising_edge(s_CLK);

	s_RADDR1 <= std_logic_vector(to_unsigned(5,5)); --reading from rs1
	s_RADDR2 <= std_logic_vector(to_unsigned(5,5)); --reading from rs2

	--overwriting register 5
	s_WE <= '1';
	s_WADDR <= std_logic_vector(to_unsigned(5,5));
	s_WDATA <= x"A312769B";
	wait until rising_edge(s_CLK);
	
	s_WE <= '0';
	wait until rising_edge(s_CLK);

	s_RADDR1 <= std_logic_vector(to_unsigned(5,5));
	s_RADDR1 <= std_logic_vector(to_unsigned(5,5));

	-- writing to register 14 and reading from register 20
	s_WE <= '1';
	s_WADDR <= std_logic_vector(to_unsigned(20,5));
	s_WDATA <= x"11115555";
	wait until rising_edge(s_CLK);
	
	s_WE <= '0';
	wait until rising_edge(s_CLK);

	s_RADDR1 <= std_logic_vector(to_unsigned(20,5));
	s_RADDR2 <= std_logic_vector(to_unsigned(20,5));


    wait;
  end process;
  
end behavior;