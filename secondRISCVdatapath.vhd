-------------------------------------------------------------------------
-- Matthew Estes
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- secondRISCVdatapath.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file is the structural implementation of the second riscv datapath
-- 09/22/2025
-------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity secondRISCVdatapath is
    port(
        i_CLK : in std_logic;
        i_RST : in std_logic;
        instr : in std_logic_vector(31 downto 0);
        alu_result : out std_logic_vector(31 downto 0);
        mem_data : out std_logic_vector(31 downto 0)
    );
end secondRISCVdatapath;


architecture structural of secondRISCVdatapath is

    component RegisterFile is
        port(
            i_RD1   : in std_logic_vector(4 downto 0);
            i_RS1   : in std_logic_vector(4 downto 0);
            i_RS2   : in std_logic_vector(4 downto 0);
            i_RST   : in STD_LOGIC;
            i_CLK   : in STD_LOGIC;
            wr_EN   : in STD_LOGIC;
            wr_DATA : in std_logic_vector(31 downto 0);
            o_RS1   : out std_logic_vector(31 downto 0);
            o_RS2   : out std_logic_vector(31 downto 0)
        );
    end component;

    component nAdd_Sub is
        generic(N : integer := 16);
        port(
            i_A, i_B : in std_logic_vector(N-1 downto 0);
            nAdd_sub : in STD_LOGIC;
            Sum : out std_logic_vector(N-1 downto 0);
            Cout : out STD_LOGIC
        );
    end component;

    component extender is
        port(
            i_12bit : in std_logic_vector(11 downto 0);
            sign_ext : in std_logic;
            o_32bit : out std_logic_vector(31 downto 0)
        );
    end component;

    component mem is
        generic(
            DATA_WIDTH : natural := 32;
            ADDR_WIDTH : natural := 10
        );
        port(
            clk   : in std_logic;
            addr  : in std_logic_vector((ADDR_WIDTH-1) downto 0);
            data  : in std_logic_vector((DATA_WIDTH-1) downto 0);
            we    : in std_logic := '1';
            q     : out std_logic_vector((DATA_WIDTH -1) downto 0)
        );
    end component;

    -- Internal Signals
    signal opcode : std_logic_vector(6 downto 0);
    signal rd     : std_logic_vector(4 downto 0);
    signal funct3 : std_logic_vector(2 downto 0);
    signal rs1    : std_logic_vector(4 downto 0);
    signal rs2    : std_logic_vector(4 downto 0);
    signal funct7 : std_logic_vector(6 downto 0);
    signal reg_data1, reg_data2, alu_input2, alu_out, mem_out, ext_out : std_logic_vector(31 downto 0);
    signal alu_control_signal : std_logic_vector(3 downto 0);
    signal reg_write_enable, alu_src, mem_to_reg, mem_write, sign_ext : std_logic;
    signal write_data : std_logic_vector(31 downto 0);
    signal sw_imm : std_logic_vector(11 downto 0);
    signal immediate_12bit : std_logic_vector(11 downto 0);
    SIGNAL nAdd_sub_en : std_logic;
    signal mem_addr : std_logic_vector(9 downto 0);
    signal rs2_actual : std_logic_vector(4 downto 0);
begin
    -- Instruction Fields
    write_data <= mem_out when mem_to_reg = '1' else alu_out when reg_write_enable = '1' else(others => '0');
    opcode <= instr(6 downto 0);
    rd <= instr(11 downto 7);
    funct3 <= instr(14 downto 12);
    rs1 <= instr(19 downto 15);
    rs2 <= instr(24 downto 20);
    funct7 <= instr(31 downto 25);
    sw_imm <= instr(31 downto 25) & instr(11 downto 7);
    sign_ext <= '1' when opcode = "0000011" or opcode = "0100011" else '0'; -- Load or Store
    immediate_12bit <= instr(31 downto 20) when (opcode = "0010011" or opcode = "0000011") else sw_imm(11 downto 0);
    nAdd_sub_en <= '0' when (opcode = "0010011") else funct7(5);
    rs2_actual <= rs2 when (opcode = "0110011" or opcode = "0100011") else "00000"; -- Use x0 for other instructions

    process(instr, opcode, funct3, funct7)
    begin
        mem_to_reg       <= '0';
        alu_src          <= '0';
        reg_write_enable <= '0';
        mem_write        <= '0';

        if opcode = "0010011" then     -- ADDI
            mem_to_reg       <= '0';
            alu_src         <= '1';    -- Use immediate
            reg_write_enable <= '1';
            mem_write       <= '0';
        elsif opcode = "0000011" then  -- LW
            mem_to_reg       <= '1';
            alu_src         <= '1';
            reg_write_enable <= '1';
            mem_write       <= '0';
        elsif opcode = "0100011" then -- SW
            mem_to_reg      <= '0';
            alu_src         <= '1';
            reg_write_enable<= '0';
            mem_write       <= '1';
        else -- R-type
            mem_to_reg      <= '0';
            alu_src         <= '0';
            reg_write_enable<= '1';
            mem_write       <= '0';
        end if;
    end process;





    -- Register File 
    reg_file_inst : RegisterFile
        port map(
            i_RD1   => rd,    
            i_RS1   => rs1,   
            i_RS2   => rs2_actual,  
            i_RST   => i_RST,
            i_CLK   => i_CLK,
            wr_EN   => reg_write_enable,
            wr_DATA => write_data,
            o_RS1   => reg_data1,
            o_RS2   => reg_data2
        );


    -- Extender 
    extender_inst : extender
        port map(
            i_12bit => immediate_12bit,
            sign_ext => sign_ext,
            o_32bit => ext_out
        );



    -- ALU Control Logic
    alu_control_signal <= "0010" when funct3 = "000" and (funct7 = "0000000" or opcode = "0010011") else
                          "0110" when funct3 = "000" and funct7 = "0100000" else
                          "0000"; -- Default to ADD
    -- ALU Input Selection aka mux logic 
    alu_input2 <= reg_data2 when alu_src = '0' else ext_out;
 
    -- ALU 
    alu_inst : nAdd_Sub
        generic map(N => 32)
        port map(
            i_A => reg_data1,
            i_B => alu_input2,
            nAdd_sub => nAdd_sub_en,
            Sum => alu_out,
            Cout => open
        );

    -- Memory Address Multiplexer
    mem_addr <= alu_out(9 downto 0) when (opcode = "0000011" or opcode = "0100011") else 
                (others => '0');

    -- Memory 
    mem_inst : mem
        generic map(
            DATA_WIDTH => 32,
            ADDR_WIDTH => 10
        )
        port map(
            clk => i_CLK,
            addr => mem_addr,  -- Use new multiplexed address
            data => reg_data2,
            we => mem_write,
            q => mem_out
        );
    


    -- Output Assignments
    alu_result <= alu_out;
    mem_data <= mem_out;
end structural;









