-- Matthew Estes
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- mux2to1_dataflow.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file is the dataflow implementation of a 2 to 1 mux
--              
-- 09/01/2025
-------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity dataflow_mux2to1 is 
	port(
		i_D0, i_D1 : in STD_LOGIC;
		i_S : in STD_LOGIC;
		o_O : out STD_LOGIC
	);
end dataflow_mux2to1;

-- This is the dataflow architecture
architecture structure of dataflow_mux2to1 is 
begin 
	o_O <= (i_D0 AND (NOT i_S)) OR (i_D1 and i_S);
	
end structure;
