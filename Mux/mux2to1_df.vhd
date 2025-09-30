-------------------------------------------------------------------------
-- Luke Olsen
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- mux2to1_df.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an implementation of an N-bit wide 2:1
-- mux using structural VHDL, 2andg, 2org, notg
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity mux2to1_df is
  port(i_S          : in std_logic;
       i_D0         : in std_logic;
       i_D1         : in std_logic;
       o_O          : out std_logic);

end mux2to1_df;

architecture dataflow of mux2to1_df is
  begin
  o_O <= i_D0 when i_S = '0' else 
	i_D1;

end dataflow;
