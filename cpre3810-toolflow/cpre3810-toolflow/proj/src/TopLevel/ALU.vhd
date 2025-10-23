-------------------------------------------------------------------------
-- Matthew Estes
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- ALU.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: this is the structural implementation of the ALU
--              
-- 10/19/2025
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity ALU is 
	port(
		A	:	in std_logic_vector(31 downto 0); -- first data input
		B	:	in std_logic_vector(31 downto 0); -- second data input
		ALUCtrl	:	in std_logic_vector(3 downto 0); -- output of the alu control
		Result	:	out std_logic_vector(31 downto 0);
		zero	:	out std_logic
	);
end ALU;

architecture structural of ALU is 


	component org2
		port(
			i_A	: in std_logic;
			i_B	: in std_logic;
			o_F	: out std_logic
		);
	end component;
	
	component xorg2
		port(
			i_A          : in std_logic;
		        i_B          : in std_logic;
		        o_F          : out std_logic
		);
	end component;
	
	component andg2
		port(
			i_A          : in std_logic;
       			i_B          : in std_logic;
       			o_F          : out std_logic
		);
	end component;
	
	component nAdd_Sub
		generic(N : integer := 32);
		port(
			i_A, i_B : in std_logic_vector(N-1 downto 0);
			nAdd_sub : in STD_LOGIC;
			Sum : out std_logic_vector(N-1 downto 0);
			Cout : out STD_LOGIC
		);

	signal and_result_b_vector : std_logic_vector(31 downto 0);
	signal or_result_b_vector : std_logic_vector(31 downto 0);
	signal xor_result_b_vector : std_logic_vector(31 downto 0);
        signal add_result_b_vector : std_logic_vector(31 downto 0);
        signal sub_result_b_vector : std_logic_vector(31 downto 0);
        signal temp_carry_out : std_logic;
        signal add_ctrl, sub_ctrl : std_logic;
        signal slt_out, sltu_out : std_logic;

begin
	    add_ctrl <= '0';
	    sub_ctrl <= '1';
	    -- and
	    and_gen: for i in 0 to 31 generate
		and_inst: andg2 port map(
		    i_A => A(i),
		    i_B => B(i),
		    o_F => and_result_b_vector(i)
		);
	    end generate;

	    -- or
	    or_gen: for i in 0 to 31 generate
		or_inst: org2 port map(
		    i_A => A(i),
		    i_B => B(i),
		    o_F => or_result_b_vector(i)
		);
	    end generate;
	    
	    -- xor
	    xor_gen: for i in 0 to 31 generate
		xor_inst: xorg2 port map(
		    i_A => A(i),
		    i_B => B(i),
		    o_F => xor_result_b_vector(i)
		);
	    end generate;

	    -- add/sub
	    add_inst: nAdd_Sub
		generic map(N => 32)
		port map(
		    i_A => A,
		    i_B => B,
		    nAdd_sub => add_ctrl,
		    Sum => add_result_b_vector,
		    Cout => temp_carry_out
		);
	   sub_inst: nAdd_Sub
		generic map(N => 32)
		port map(
		    i_A => A,
		    i_B => B,
		    nAdd_sub => sub_ctrl,
		    Sum => sub_result_b_vector,
		    Cout => temp_carry_out
		);
		
		-- SLT == 0111, SLTU == 1100, SLL == 1001, SRL = 1010, SRA = 1011
		
		
	   with ALUCtrl select
		Result <= and_result_b_vector when "0000", -- and
		          or_result_b_vector  when "0001", -- or
		          add_result_b_vector when "0010", -- add
		          add_result_b_vector when "0110", -- sub 
		          xor_result_b_vector when "1000"; -- xor
		          (others => '0') when others;
    	   zero <= '1' when Result = (others => '0') else '0';
		
    
end behavior;

