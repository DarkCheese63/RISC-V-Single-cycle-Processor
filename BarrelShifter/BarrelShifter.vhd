-------------------------------------------------------------------
-- BarrelShifter:
-- Reference Schematic for signals
-------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_STD.all;

entity barrelShifter is 
    generic(N : integer := 32;
	  ALUWIDTH : integer := 4);

  port(ALUsel         : in std_logic_vector(ALUWIDTH-1 downto 0);
       iA               : in std_logic_vector(N-1 downto 0); --input a
       iB               : in std_logic_vector(N-1 downto 0); --input b
       ALU               : out std_logic_vector(N-1 downto 0)); --output 
end barrelShifter;

architecture dataflow of barrelShifter is
 begin

 process(iA, iB, ALUsel)
    variable A_s : signed(N-1 downto 0);
    variable B_s : signed(N-1 downto 0);
    variable A_u : unsigned(N-1 downto 0);
    variable B_u : unsigned(N-1 downto 0);
    variable temp : std_logic_vector(N-1 downto 0);
 begin
    A_s := signed(iA);
    B_s := signed(iB);
    A_u := unsigned(iA);
    B_u := unsigned(iB);

    case ALUsel is --add more when "ALUsel value" => execute op for wanted val
	when "0101" => --slt
	  if A_s < B_s then 
		temp := (others => '0');
		temp(0) := '1';
	  else 
		temp := (others => '0');
	  end if;

	when "0110" => --sltu
	  if A_u < B_u then 
		temp := (others => '0');
		temp(0) := '1';
	  else 
		temp := (others => '0');
	  end if;

	when "0111" => --sll
	  temp := std_logic_vector(shift_left(A_u, to_integer(B_u(4 downto 0))));

	when "1000" => --srl
	  temp := std_logic_vector(shift_right(A_u, to_integer(B_u(4 downto 0))));

	when "1001" => --sra
	  temp := std_logic_vector(shift_right(A_s, to_integer(B_u(4 downto 0))));

	when others =>
	  temp := (others => '0');
	end case;
	
	ALU <= temp;
        
    end process;
end dataflow;