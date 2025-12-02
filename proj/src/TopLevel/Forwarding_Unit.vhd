-- forwarding unit
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
entity Forwarding_Unit is
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
end Forwarding_Unit;

architecture Behaviour of Forwarding_Unit is
begin
	process(i_ID_EX_RS1,i_ID_EX_RS2,i_EX_MEM_RD,i_EX_MEM_RegWr,i_MEM_WB_RD,i_MEM_WB_RegWr)
	begin
		-- base case automatic no forward
		o_ForwardA <= "00";
		o_ForwardB <= "00";
		
		-- forward from EX/MEM 
		if (i_EX_MEM_RegWr = '1') and (i_EX_MEM_RD /= "00000") and (i_EX_MEM_RD = i_ID_EX_RS1) then
			o_ForwardA <= "10";
		-- if not then check the instruction 2 cycles ahead or the previous previous instruction
		elsif (i_MEM_WB_RegWr = '1') and (i_MEM_WB_RD /= "00000") and (i_MEM_WB_RD = i_ID_EX_RS1) then
			o_ForwardA <= "01";
		end if;
		
		-- same logic but for RS2
		if (i_EX_MEM_RegWr = '1') and (i_EX_MEM_RD /= "00000") and (i_EX_MEM_RD = i_ID_EX_RS2) then
			o_ForwardB <= "10";
		elsif (i_MEM_WB_RegWr = '1') and (i_MEM_WB_RD /= "00000") and (i_MEM_WB_RD = i_ID_EX_RS2) then
			o_ForwardB <= "01";
		end if;
	end process;
end Behaviour;
	
	
	
