-------------------------------------------------------------------
-- Control Unit:
-- Reference Schematic for signals
-------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

entity controlUnit is 
	generic (N : integer := 32);
		-- control data will grab these bits from bus 9[6:0] & 9[30, 14:12]. Reference schematic
	port(   c_IN     : in std_logic_vector(N-1 downto 0); 
		ImmSel   : out std_logic_vector(2 downto 0);
		s_RegWr  : out std_logic;
		BrUn     : out std_logic;
		Asel     : out std_logic;
		Bsel     : out std_logic;
		ALUSel   : out std_logic_vector(3 downto 0);
		s_DMemWr : out std_logic;
		WBSel    : out std_logic_vector(1 downto 0));
end controlUnit;

architecture dataflow of controlUnit is
	signal opcode  : std_logic_vector(6 downto 0); -- bits 6:0
	signal funct3  : std_logic_vector(2 downto 0); -- bits 14:12
	signal funct7  : std_logic; -- bit 30
	signal control : std_logic_vector(7 downto 0); -- grouping control signals

  begin
  	opcode <= c_IN(6 downto 0);
  	funct3 <= c_IN(14 downto 12);
  	funct7 <= c_IN(30);
  	
  process(opcode)
	begin
	case opcode is
	when "0110011" => -- R
	  ImmSel <= "000";
	  s_RegWr <= '1';
	  BrUn <= '0';
	  Asel <= '0';
	  Bsel <= '0';
	  s_DMemWr <= '0';
	  WBSel <= "00";
	
	when "0010011" => -- I
	  ImmSel <= "001";
	  s_RegWr <= '1';
	  BrUn <= '0';
	  Asel <= '0';
	  Bsel <= '1';
	  s_DMemWr <= '0';
	  WBSel <= "00";

	when "0000011" => -- Load
	  ImmSel <= "010";
	  s_RegWr <= '1';
	  BrUn <= '0';
	  Asel <= '0';
	  Bsel <= '1';
	  s_DMemWr <= '0';
	  WBSel <= "01";

	when "0100011" => -- Store
	  ImmSel <= "011";
	  s_RegWr <= '0';
	  BrUn <= '0';
	  Asel <= '0';
	  Bsel <= '1';
	  s_DMemWr <= '1';
	  WBSel <= "00";

	when "1100011" => -- Branch
	  ImmSel <= "100";
	  s_RegWr <= '0';
	  BrUn <= '0';
	  Asel <= '1';
	  Bsel <= '0';
	  s_DMemWr <= '0';
	  WBSel <= "00";

	when "1101111" => -- JAL
	  ImmSel <= "101";
	  s_RegWr <= '1';
	  BrUn <= '0';
	  Asel <= '1';
	  Bsel <= '1';
	  s_DMemWr <= '0';
	  WBSel <= "10";

	when "1100111"=> -- JALR
	  ImmSel <= "110";
	  s_RegWr <= '1';
	  BrUn <= '0';
	  Asel <= '1';
	  Bsel <= '1';
	  s_DMemWr <= '0';
	  WBSel <= "10";

	when "0110111"=> -- LUI
	  ImmSel <= "111";
	  s_RegWr <= '1';
	  BrUn <= '0';
	  Asel <= '1';
	  Bsel <= '1';
	  s_DMemWr <= '0';
	  WBSel <= "10";

	when "0010111"=> -- AUIPC
	  ImmSel <= "111";
	  s_RegWr <= '1';
	  BrUn <= '0';
	  Asel <= '1';
	  Bsel <= '1';
	  s_DMemWr <= '0';
	  WBSel <= "10";

	when "0000000"=> -- Halt
	  ImmSel <= "000";
	  s_RegWr <= '0';
	  BrUn <= '0';
	  Asel <= '0';
	  Bsel <= '0';
	  s_DMemWr <= '0';
	  WBSel <= "00";

	when others => -- default
	  ImmSel <= "000";
	  s_RegWr <= '0';
	  BrUn <= '0';
	  Asel <= '0';
	  Bsel <= '0';
	  s_DMemWr <= '0';
	  WBSel <= "00";
  end case;
  end process;

  process(opcode, funct3, funct7)
  begin
	case opcode is
	when "0110011" => case funct3 is -- R type
	when "000" => 
	  if funct7 = '1' then
		ALUSel <= "0001"; -- sub
	  else
	  	ALUSel <= "0000"; -- add
	  end if;
	when "111" => ALUSel <= "0010"; -- and
	when "110" => ALUSel <= "0011"; -- or
	when "100" => ALUSel <= "0100"; -- xor
	when "010" => ALUSel <= "0101"; -- slt
	when "011" => ALUSel <= "0110"; -- sltu
	when "001" => ALUSel <= "0111"; -- sll
	if funct7 = '1' then
		ALUSel <= "1001"; -- sra
	  else
	  	ALUSel <= "1000"; -- srl
	  end if;
        when others => ALUSel <= "0000";
	end case;

	when "0010011" => case funct3 is -- I type
	when "000" => ALUSel <= "0000"; -- addi
	when "010" => ALUSel <= "0101"; -- slti
	when "011" => ALUSel <= "0110"; -- sltiu
	when "111" => ALUSel <= "0010"; -- andi
	when "110" => ALUSel <= "0011"; -- ori
	when "100" => ALUSel <= "0100"; -- xori
	when "001" => ALUSel <= "0111"; -- slli
	if funct7 = '1' then
		ALUSel <= "1001"; -- srai
	  else
	  	ALUSel <= "1000"; -- srli
	  end if;
	when others => ALUSel <= "0000"; 
	end case;

	when others =>
	    ALUSel <= "0000";
	  end case;
	end process;

end dataflow;
