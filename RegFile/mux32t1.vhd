-------------------------------------------------------------------
-- Mux: 32:1 mux 
--
-- Required signals:
-------------------------------------------------------------------
-- d_IN: in std_logic_vector(32 downto 0);
-- f_OUT: out std_logic;
-------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

entity mux32t1 is 
	generic (N : integer := 32;
		 I : integer := 5);
	port(reg0, reg1, reg2, reg3, reg4, reg5, reg6, reg7, reg8, reg9, reg10,
	     reg11, reg12, reg13, reg14, reg15, reg16, reg17, reg18, reg19, reg20,
	     reg21, reg22, reg23, reg24, reg25, reg26, reg27, reg28, reg29, reg30, reg31   : in std_logic_vector(N-1 downto 0);
	     i_S   : in std_logic_vector(I-1 downto 0);
	     f_OUT : out std_logic_vector(N-1 downto 0));
end mux32t1;

architecture dataflow of mux32t1 is
  begin
		-- used genAI to generate 32 lines cause its repetitive
	f_OUT <= reg0 when i_S = "00000" else
	   reg1  when i_S = "00001" else
           reg2  when i_S = "00010" else
           reg3  when i_S = "00011" else
           reg4  when i_S = "00100" else
           reg5  when i_S = "00101" else
           reg6  when i_S = "00110" else
           reg7  when i_S = "00111" else
           reg8  when i_S = "01000" else
           reg9  when i_S = "01001" else
           reg10 when i_S = "01010" else
           reg11 when i_S = "01011" else
           reg12 when i_S = "01100" else
           reg13 when i_S = "01101" else
           reg14 when i_S = "01110" else
           reg15 when i_S = "01111" else
           reg16 when i_S = "10000" else
           reg17 when i_S = "10001" else
           reg18 when i_S = "10010" else
           reg19 when i_S = "10011" else
           reg20 when i_S = "10100" else
           reg21 when i_S = "10101" else
           reg22 when i_S = "10110" else
           reg23 when i_S = "10111" else
           reg24 when i_S = "11000" else
           reg25 when i_S = "11001" else
           reg26 when i_S = "11010" else
           reg27 when i_S = "11011" else
           reg28 when i_S = "11100" else
           reg29 when i_S = "11101" else
           reg30 when i_S = "11110" else
           reg31 when i_S = "11111" else
           (others => '0');  -- default

end dataflow;