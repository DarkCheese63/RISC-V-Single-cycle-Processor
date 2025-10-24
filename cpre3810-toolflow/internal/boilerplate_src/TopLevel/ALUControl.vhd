-------------------------------------------------------------------------
-- Matthew Estes
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- ALUControl.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: this is the behavioral implementation of the ALU control
--              
-- 10/19/2025
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity ALUControl is 
	port(
		ALUOp	:	in std_logic_vector(1 downto 0); -- opcode
		Funct3	:	in std_logic_vector(2 downto 0); -- funct 3
		Funct7	:	in std_logic_vector(6 downto 0); -- funct 7
		ALUCtrl	:	out std_logic_vector(3 downto 0) -- operation to be done sent to the alu
	);
end ALUControl;

architecture behavioral of ALUControl is
begin
process(ALUOp, Funct3, Funct7)
begin
  case ALUOp is
    when "00" => ALUCtrl <= "0010"; -- add (for load/store)
    when "01" => ALUCtrl <= "0110"; -- sub (for branch)
    when "10" => -- R-type or I-type
      case Funct3 is
	  
        when "000" =>
          if Funct7 = "0100000" then
            ALUCtrl <= "0110"; -- SUB
          else
            ALUCtrl <= "0010"; -- ADD
          end if;
		  
        when "111" => ALUCtrl <= "0000"; -- AND
        when "110" => ALUCtrl <= "0001"; -- OR
        when "100" => ALUCtrl <= "1000"; -- XOR
        when "001" => ALUCtrl <= "1001"; -- SLL
		
        when "101" =>
          if Funct7 = "0100000" then
            ALUCtrl <= "1011"; -- SRA
          else
            ALUCtrl <= "1010"; -- SRL
          end if;
		  
        when "010" => ALUCtrl <= "0111"; -- SLT
		when "011" => ALUCtrl <= "1100"; -- SLTU
        when others => ALUCtrl <= "0000";
      end case;
    when others =>
      ALUCtrl <= "0010"; -- default add
  end case;
end process;

end behavioral;

