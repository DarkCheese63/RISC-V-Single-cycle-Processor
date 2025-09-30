-------------------------------------------------------------------------
-- Luke Olsen
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- tb_dmem.vhd.vhd
-------------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_dmem is
generic(gCLK_HPER   : time := 50 ns);
end tb_dmem;

architecture behavior of tb_dmem is
  
  -- Calculate the clock period as twice the half-period
  constant DATA_WIDTH : integer := 32;
  constant ADDR_WIDTH : integer := 10;


  component mem
    generic(DATA_WIDTH : natural := 32;
	ADDR_WIDTH : natural := 10);
	port 
	(
		clk		: in std_logic;
		addr	        : in std_logic_vector((ADDR_WIDTH-1) downto 0);
		data	        : in std_logic_vector((DATA_WIDTH-1) downto 0);
		we		: in std_logic := '1';
		q		: out std_logic_vector((DATA_WIDTH -1) downto 0)
	);


  end component;

  -- Temporary signals to connect to the dff component.
       signal s_CLK          :  std_logic := '0';
	signal s_ADDR : std_logic_vector((ADDR_WIDTH-1) downto 0) := (others => '0');
	signal s_DATA :std_logic_vector((DATA_WIDTH-1) downto 0) := (others => '0');
	signal s_WE : std_logic := '0';
	signal s_Q : std_logic_vector((DATA_WIDTH-1) downto 0);


begin

  dmem: mem
	generic map(DATA_WIDTH => DATA_WIDTH, ADDR_WIDTH => ADDR_WIDTH)
  	port map(clk => s_CLK, 
           addr => s_ADDR,
           data  => s_DATA,
           we  => s_WE,
           q  => s_Q);

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
	-- FIX ME
	for i in 0 to 9 loop --get data
	  s_ADDR <= std_logic_vector(to_unsigned(i, ADDR_WIDTH));
	  s_WE <= '0';
	  wait until rising_edge(s_CLK);
	  s_WE <= '1';
	  wait until rising_edge(s_CLK);
	  s_ADDR <= std_logic_vector(to_unsigned(16#100# + i, ADDR_WIDTH));
	  s_DATA <= s_Q;
	  wait until rising_edge(s_CLK);
	  s_WE <= '0';
	end loop;

									  
	 for i in 0 to 9 loop
	  s_ADDR <= std_logic_vector(to_unsigned(16#100# + i, ADDR_WIDTH));
	  s_WE <= '0';
	  wait until rising_edge(s_CLK);
	  wait for 10 ns;
	end loop;

    wait;
  end process;
  
end behavior;