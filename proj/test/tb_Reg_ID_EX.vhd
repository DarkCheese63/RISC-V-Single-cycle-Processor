library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_Reg_ID_EX is
end tb_Reg_ID_EX;

architecture Behavioral of tb_Reg_ID_EX is

    component Reg_ID_EX is 
    generic(N : integer := 32);
    port(
        i_CLK   : in STD_LOGIC;
        i_RST   : in STD_LOGIC;
        i_WE    : in STD_LOGIC;
        i_FLUSH : in STD_LOGIC;

        -- Control Inputs
        i_SRegWr, i_BrUn, i_Asel, i_Bsel, i_SDMemWr, i_SHALT, i_BR : in std_logic_vector(0 downto 0);
        i_WBSel : in std_logic_vector(1 downto 0);
        i_funct3 : in std_logic_vector(2 downto 0);
        i_ALUSel : in std_logic_vector(3 downto 0);
        
        -- Data Inputs
        i_RS1, i_RS2, i_PC, i_PCP4, i_ImmOut, i_INST : in std_logic_vector(N-1 downto 0);
        i_RD : in std_logic_vector(4 downto 0);

        -- Control Outputs
        o_SRegWr, o_BrUn, o_Asel, o_Bsel, o_SDMemWr, o_SHALT, o_BR : out std_logic;
        o_WBSel : out std_logic_vector(1 downto 0);
        o_funct3 : out std_logic_vector(2 downto 0);
        o_ALUSel : out std_logic_vector(3 downto 0);
        
        -- Data Outputs
        o_RS1, o_RS2, o_PC, o_PCP4, o_ImmOut, o_INST : out std_logic_vector(N-1 downto 0);
        o_RD : out std_logic_vector(4 downto 0)
    );
    end component;

    -- Signals
    signal s_CLK, s_RST, s_WE, s_FLUSH : std_logic := '0';
    
    -- Inputs
    signal s_i_RS1 : std_logic_vector(31 downto 0) := (others => '0');
    signal s_i_RD  : std_logic_vector(4 downto 0) := (others => '0');
    
    
    -- Outputs
    signal s_o_RS1 : std_logic_vector(31 downto 0);
    signal s_o_RD  : std_logic_vector(4 downto 0);
    
    constant CLK_PERIOD : time := 10 ns;

begin
    
    UUT: Reg_ID_EX
    port map (
        i_CLK => s_CLK, 
        i_RST => s_RST, 
        i_WE => s_WE, 
        i_FLUSH => s_FLUSH,

        i_RS1 => s_i_RS1, 
        o_RS1 => s_o_RS1,
        i_RD  => s_i_RD,  
        o_RD  => s_o_RD,
        
        -- Tie the rest to dummy zeros for the testbench to compile
        i_SRegWr => "0", 
        i_BrUn => "0", 
        i_Asel => "0", 
        i_Bsel => "0", 
        i_SDMemWr => "0", 
        i_SHALT => "0", 
        i_BR => "0",
        i_WBSel => "00", 
        i_funct3 => "000", 
        i_ALUSel => "0000",
        i_RS2 => (others=>'0'), 
        i_PC => (others=>'0'), 
        i_PCP4 => (others=>'0'), 
        i_ImmOut => (others=>'0'), 
        i_INST => (others=>'0')
        
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
        s_i_RS1 <= x"AAAAAAAA"; -- Test Pattern 1
        s_i_RD  <= "00101";     -- Register 5
        wait for CLK_PERIOD;
        -- load AAAAAAAA
        
        -- 3. Stall (WE=0)
        s_WE <= '0';
        s_i_RS1 <= x"BBBBBBBB"; -- Change input
        wait for CLK_PERIOD;
        -- AAAAAAAA (should hold because of stall)
        
        -- 4. Flush (FLUSH=1)
        s_WE <= '1';   -- Enable write logic
        s_FLUSH <= '1'; -- But Flush overrides it
        s_i_RS1 <= x"CCCCCCCC";
        wait for CLK_PERIOD;
        -- should flush to 00000000

        wait;
    end process;

end Behavioral;
