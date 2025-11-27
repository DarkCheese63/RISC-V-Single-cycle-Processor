-- this is the hazard detection unit
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity HDU is 
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
end HDU;
	
architecture behaviour of HDU is
begin 
	process(i_ID_EX_MemRead, i_ID_EX_RD, i_IF_ID_RS1, i_IF_ID_RS2, i_Branch_Taken)
	begin
		-- set default values
		o_PC_Write <= '1';
		o_IF_ID_Write <= '1';
		o_IF_Id_Flush <= '0';
		o_ID_EX_Flush <= '0';
		
		-- control hazard
		-- check if branch taken 
		-- if we take the branch then everything in the fetch/decode needs to be flushed 
		-- because it is not the instruction we need
		if (i_Branch_Taken = '1') then
			o_IF_ID_Flush <= '1';
			o_ID_EX_Flush <= '1';
			
		-- load use hazard
		-- check if previous instruction was a load 
		-- make sure the register is not the zero register
		elsif (i_ID_EX_MemRead = '1') and (i_ID_EX_RD /= "00000") then
		
			-- does the loading instr in EX write to a register needed in the ID stage
			-- if the current instruction in the EX stage writes to a register the instr in the ID stage needs
			-- then do these actions
			if(i_ID_EX_RD = i_IF_ID_RS1) or (i_ID_EX_RD = i_IF_ID_RS2) then
				o_PC_Write <= '0'; -- stall PC
				o_IF_ID_Write <= '0'; -- stall IF/ID
				o_ID_EX_Flush <= '1'; -- flush ID/EX
			end if;
		end if;
	end process;
end behaviour;
