-------------------------------------------------------------------------
-- Matthew Estes
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- OnesComp.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: The purpose of this file is to take a single input and negate each bit
--              
-- 09/03/2025
-------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity OnesComp is 
	generic(N : integer := 16);
	port(
		i_D1 : in std_logic_vector(N-1 downto 0);
		o_O : out std_logic_vector(N-1 downto 0)
	);
end OnesComp;

architecture structure of OnesComp is
	
	component invg
		port(
			i_A : in STD_LOGIC;
			o_F : out STD_LOGIC
		);
	end component;
	
	begin 
		G_NBit_INV: for i in 0 to N-1 generate
			INV_I: invg port map(
				i_A => i_D1(i),
				o_F => o_O(i)
			);
		end generate G_NBit_INV;
end structure;