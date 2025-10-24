library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_branch_comp is
end tb_branch_comp;

architecture sim of tb_branch_comp is
  -- DUT signals
  signal i_A, i_B : std_logic_vector(31 downto 0);
  signal i_BrUn        : std_logic;
  signal i_funct3      : std_logic_vector(2 downto 0);
  signal o_Branch       : std_logic;
  signal clk : std_logic := '0';
begin

  -- Instantiate DUT
  uut: entity work.branch_comp
    port map(
      i_A => i_A,
      i_B => i_B,
      i_BrUn => i_BrUn,
      i_funct3 => i_funct3,
      o_Branch => o_Branch
    );

  -- Clock (optional, for viewing changes)
  clk <= not clk after 100 ns;

  -- Stimulus
  process
  begin

    -- BEQ: equal
    i_BrUn <= '0';
    i_funct3 <= "000";  -- BEQ
    i_A <= x"00000005";
    i_B <= x"00000005";
    wait for 100 ns;

    -- BNE: not equal
    i_funct3 <= "001";  -- BNE
    i_A <= x"00000005";
    i_B <= x"00000006";
    wait for 100 ns;

    -- BLT signed: rs1 < rs2
    i_funct3 <= "100";  -- BLT
    i_A <= std_logic_vector(to_signed(-2, 32));
    i_B <= std_logic_vector(to_signed(5, 32));
    wait for 100 ns;

    -- BGE signed: rs1 >= rs2
    i_funct3 <= "101";  -- BGE
    i_A <= std_logic_vector(to_signed(10, 32));
    i_B <= std_logic_vector(to_signed(-3, 32));
    wait for 100 ns;

    -- BLTU unsigned: rs1 < rs2
    i_BrUn <= '1';
    i_funct3 <= "100";  -- BLTU
    i_A <= x"00000001";
    i_B <= x"00000005";
    wait for 100 ns;

    -- BGEU unsigned: rs1 >= rs2
    i_funct3 <= "101";  -- BGEU
    i_A <= x"FFFFFFFE";  -- large unsigned
    i_B <= x"00000001";
    wait for 100 ns;

    wait;
  end process;

end sim;
