-------------------------------------------------------------------------
-- Luke Olsen
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- reg_file.vhd
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity reg_file is
  generic(N : integer := 32);
  port(i_CLK          : in std_logic;
       i_RST          : in std_logic;
       i_WE           : in std_logic;
       i_WADDR	      : in std_logic_vector(4 downto 0); --write address
       i_WDATA 	      : in std_logic_vector(N-1 downto 0); --write data
       i_RADDR1	      : in std_logic_vector(4 downto 0); -- rs1
       i_RADDR2	      : in std_logic_vector(4 downto 0); -- rs2
       o_RDATA1	      : out std_logic_vector(N-1 downto 0);
       o_RDATA2	      : out std_logic_vector(N-1 downto 0));

end reg_file;

architecture structural of reg_file is
  component reg_N
	generic(N : integer := 32);
	port(i_CLK : in std_logic;
	     i_RST : in std_logic;
	     i_WE  : in std_logic;
	     i_D   : in std_logic_vector(N-1 downto 0);
             o_Q   : out std_logic_vector(N-1 downto 0));
  end component;

  component decoder5t32
	generic(N : integer := 32; I : integer := 5);
	port(d_IN : in std_logic_vector(I-1 downto 0);
	     f_OUT : out std_logic_vector(N-1 downto 0));
  end component;

  component mux32t1
	generic(N : integer := 32; I : integer := 5);
	port(reg0, reg1, reg2, reg3, reg4, reg5, reg6, reg7, reg8, reg9, reg10,
	     reg11, reg12, reg13, reg14, reg15, reg16, reg17, reg18, reg19, reg20,
	     reg21, reg22, reg23, reg24, reg25, reg26, reg27, reg28, reg29, reg30, 
	     reg31 : in std_logic_vector(N-1 downto 0);
	     i_S   : in std_logic_vector(I-1 downto 0);
	     f_OUT : out std_logic_vector(N-1 downto 0));
  end component;

  signal i_decode : std_logic_vector(31 downto 0);
  type reg_array_t is array (0 to 31) of std_logic_vector(N-1 downto 0);
  signal s_reg : reg_array_t;

begin


  DEC0 : decoder5t32
	generic map(N => N, I => 5)
	port map(d_IN => i_WADDR, 
		f_OUT => i_decode);

  DEC1 : reg_N
	generic map(N => N)
	port map(i_CLK => i_CLK,
		 i_RST => '1',
		 i_WE  => '0',
		 i_D => (others => '0'),
		 o_Q => s_reg(0));

  gen_regs: for idx in 1 to 31 generate
	DEC2: reg_N 
	  generic map(N => N)
		port map (i_CLK => i_CLK,
			  i_RST => i_RST,
			  i_WE => i_WE and i_decode(idx),
			  i_D => i_WDATA,
			  o_Q => s_reg(idx));
  end generate gen_regs;

    DUT3 : mux32t1 
	generic map(N => N, I => 5)
   	port map(
	reg0  => s_reg(0),  reg1  => s_reg(1),  reg2  => s_reg(2),  reg3  => s_reg(3),
      reg4  => s_reg(4),  reg5  => s_reg(5),  reg6  => s_reg(6),  reg7  => s_reg(7),
      reg8  => s_reg(8),  reg9  => s_reg(9),  reg10 => s_reg(10), reg11 => s_reg(11),
      reg12 => s_reg(12), reg13 => s_reg(13), reg14 => s_reg(14), reg15 => s_reg(15),
      reg16 => s_reg(16), reg17 => s_reg(17), reg18 => s_reg(18), reg19 => s_reg(19),
      reg20 => s_reg(20), reg21 => s_reg(21), reg22 => s_reg(22), reg23 => s_reg(23),
      reg24 => s_reg(24), reg25 => s_reg(25), reg26 => s_reg(26), reg27 => s_reg(27),
      reg28 => s_reg(28), reg29 => s_reg(29), reg30 => s_reg(30), reg31 => s_reg(31),
	    i_S => i_RADDR1,
	    f_OUT => o_RDATA1);

  DUT4 : mux32t1 
	generic map(N => N, I => 5)
   	port map(
	reg0  => s_reg(0),  reg1  => s_reg(1),  reg2  => s_reg(2),  reg3  => s_reg(3),
      reg4  => s_reg(4),  reg5  => s_reg(5),  reg6  => s_reg(6),  reg7  => s_reg(7),
      reg8  => s_reg(8),  reg9  => s_reg(9),  reg10 => s_reg(10), reg11 => s_reg(11),
      reg12 => s_reg(12), reg13 => s_reg(13), reg14 => s_reg(14), reg15 => s_reg(15),
      reg16 => s_reg(16), reg17 => s_reg(17), reg18 => s_reg(18), reg19 => s_reg(19),
      reg20 => s_reg(20), reg21 => s_reg(21), reg22 => s_reg(22), reg23 => s_reg(23),
      reg24 => s_reg(24), reg25 => s_reg(25), reg26 => s_reg(26), reg27 => s_reg(27),
      reg28 => s_reg(28), reg29 => s_reg(29), reg30 => s_reg(30), reg31 => s_reg(31),
	    i_S => i_RADDR2,
	    f_OUT => o_RDATA2);

end structural;