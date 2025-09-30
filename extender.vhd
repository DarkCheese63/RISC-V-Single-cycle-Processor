-------------------------------------------------------------------------
-- Matthew Estes
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- extender.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This module extends a 12-bit input to a 32-bit output.
--              It can perform sign extension or zero extension based on the
--              sign_ext input signal.
-- 09/22/2025
-------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity extender is
    port(
        i_12bit : in std_logic_vector(11 downto 0);
        sign_ext : in std_logic;
        o_32bit : out std_logic_vector(31 downto 0)
    );
end extender;

architecture structural of extender is
begin
    process(i_12bit, sign_ext)
    begin
        if sign_ext = '1' then
            if i_12bit(11) = '1' then
                o_32bit <= (others => '1');
                o_32bit(11 downto 0) <= i_12bit;
            else
                o_32bit <= (others => '0');
                o_32bit(11 downto 0) <= i_12bit;
            end if;
        else
            o_32bit <= (others => '0');
            o_32bit(11 downto 0) <= i_12bit;
        end if;
    end process;
end structural;

