-------------------------------------------------------------------------
-- Matthew Estes
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- InstructionMemory.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: this is the Instruction memory 
--              
-- 10/07/2025
-------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity InstructionMemory is
	port(
        clk          :   in std_logic;
		s_IMemAddr   :   in std_logic_vector(11 downto 2); -- PC[11:2]
		s_Inst       :   out std_logic_vector(31 downto 0) -- Instruction

	);
end InstructionMemory;
architecture behavioral of InstructionMemory is

 signal s_fake_data  :  std_logic_vector(31 downto 0) := (others => '0');
 signal s_fake_we    :  std_logic := '0';

begin
 iMEM: entity work.mem
     port map(
         clk  => clk,
         addr => s_IMemAddr,
         data => s_fake_data,
         we   => s_fake_we,
         q    => s_Inst
     );
end behavioral;




-- below is the test with instructions in pre loaded memory





-------------------------------------------------------------------------
-- Matthew Estes
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- InstructionMemory.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: this is the Instruction memory 
--              
-- 10/07/2025
-------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity InstructionMemory is
	port(
        clk          :   in std_logic;
		s_IMemAddr   :   in std_logic_vector(11 downto 2); -- PC[11:2]
		s_Inst       :   out std_logic_vector(31 downto 0) -- Instruction

	);
end InstructionMemory;
architecture behavioral of InstructionMemory is

    type mem_array is array (0 to 63) of std_logic_vector(31 downto 0);
    signal imem : mem_array := (
        0 => x"00000093",  -- addi x1, x0, 0
        1 => x"00100113",  -- addi x2, x0, 1
        2 => x"002081B3",  -- add  x3, x1, x2
        3 => x"00310233",  -- add  x4, x2, x3
        4 => x"0000006F",  -- jal  x0, 0 (infinite loop)
        others => x"00000000"
    );

begin

    process(clk)
    begin
        if rising_edge(clk) then
            s_Inst <= imem(to_integer(unsigned(s_IMemAddr)));
        end if;
    end process;



end behavioral;
        	