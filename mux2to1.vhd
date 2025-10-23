-------------------------------------------------------------------------
-- Matthew Estes
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- mux2t1.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file is the structural implementation of a 2 to 1 mux
--              
-- 09/01/2025
-------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity mux2to1 is 
	port(
		i_D0, i_D1 : in STD_LOGIC;
		i_S : in STD_LOGIC;
		o_O : out STD_LOGIC
	);
end mux2to1;

architecture structure of mux2to1 is 

	-- component declarations
	component andg2
		port(
			i_A, i_B : in STD_LOGIC;
			o_F : out STD_LOGIC
		);
	end component;
	
	component invg
		port(
			i_A : in STD_LOGIC;
			o_F : out STD_LOGIC
		);
	end component;
	
	component org2
		port(
			i_A, i_B : in STD_LOGIC;
			o_F : out STD_LOGIC
		);
	end component;
	
	-- internal signals
	signal b_sel  : STD_LOGIC;
	signal a_sel  : STD_LOGIC;
	signal notS   : STD_LOGIC;
	
begin 
	-- NOT S
	U1: invg port map(i_A => i_S, o_F => notS);
	
	-- A and not S
	U2: andg2 port map(i_A => i_D0, i_B => notS, o_F => a_sel);
	
	-- B and S 
	U3: andg2 port map(i_A => i_D1, i_B => i_S, o_F => b_sel);

	-- a_sel or b_sel
	U4: org2 port map(i_A => a_sel, i_B => b_sel, o_F => o_O);
	
end structure;
