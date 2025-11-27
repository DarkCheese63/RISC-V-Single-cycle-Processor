library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_Reg_IF_ID is
end tb_Reg_IF_ID;

architecture Behavioral of tb_Reg_IF_ID is

    component Reg_IF_ID is 
    generic(N : integer := 32);
    port(
        i_CLK : in STD_LOGIC;
        i_RST : in STD_LOGIC;
        i_WE  : in STD_LOGIC;
        i_FLUSH : in STD_LOGIC;

        -- Data Inputs
        i_PC     : in std_logic_vector(N-1 downto 0);
        i_PCP4   : in std_logic_vector(N-1 downto 0);
        i_INST   : in std_logic_vector(N-1 downto 0);

        -- Data Outputs
        o_PC     : out std_logic_vector(N-1 downto 0);
        o_PCP4   : out std_logic_vector(N-1 downto 0);
        o_INST   : out std_logic_vector(N-1 downto 0)
    );
    end component;

    -- Signals
    signal s_CLK, s_RST, s_WE, s_FLUSH : std_logic := '0';
    
    -- Inputs
    signal s_i_PC   : std_logic_vector(31 downto 0) := (others => '0');
    signal s_i_INST : std_logic_vector(31 downto 0) := (others => '0');
    
    -- Outputs
    signal s_o_PC   : std_logic_vector(31 downto 0);
    signal s_o_INST : std_logic_vector(31 downto 0);
    
    constant CLK_PERIOD : time := 10 ns;

begin
    
    UUT: Reg_IF_ID
    port map (
        i_CLK => s_CLK, 
        i_RST => s_RST, 
        i_WE => s_WE, 
        i_FLUSH => s_FLUSH,

        i_PC => s_i_PC, 
        o_PC => s_o_PC,
        i_INST => s_i_INST,  
        o_INST => s_o_INST,
        
        -- Tie the rest to dummy zeros for the testbench to compile
        i_PCP4 => (others=>'0')
    );

    -- Clock Process
    clk_proc: process
    begin
        while true loop
            s_CLK <= '0'; wait for CLK_PERIOD/2;
            s_CLK <= '1'; wait for CLK_PERIOD/2;
        end loop;
    end process;

    -- Test Process
    stim_proc: process
    begin
        -- 1. Reset
        s_RST <= '1'; s_WE <= '0'; s_FLUSH <= '0';
        wait for CLK_PERIOD*2;
        s_RST <= '0';
        wait for CLK_PERIOD;
        
        -- 2. Normal Load
        s_WE <= '1';
        s_i_PC <= x"AAAAAAAA"; -- Test Pattern 1
        s_i_INST <= x"11111111"; 
        wait for CLK_PERIOD;
        -- load AAAAAAAA
        
        -- 3. Stall (WE=0)
        s_WE <= '0';
        s_i_PC <= x"BBBBBBBB"; -- Change input
        wait for CLK_PERIOD;
        -- AAAAAAAA (should hold because of stall)
        
        -- 4. Flush (FLUSH=1)
        s_WE <= '1';   -- Enable write logic
        s_FLUSH <= '1'; -- But Flush overrides it
        s_i_PC <= x"CCCCCCCC";
        wait for CLK_PERIOD;
         -- should flush to 00000000
        
      
        wait;
    end process;

end Behavioral;
