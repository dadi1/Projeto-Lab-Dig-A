--====================================--
-- Narayan Shimanoe Lisboa - 14600141 --
-- Hugo dos Reis - 12544308           --  
--====================================--

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity LineStatusRegister is
    port(
        clk          : in  std_logic;
        rst          : in  std_logic;
        data_valid   : in  std_logic;
        parity_error : in  std_logic;
        lsr_out      : out std_logic_vector(7 downto 0)
    );
end LineStatusRegister;

architecture behaviour of LineStatusRegister is
begin
    process(clk, rst)
    begin
        if rst = '1' then
            lsr_out <= (others => '0');
        elsif rising_edge(clk) then
            lsr_out <= (
                2 => parity_error,
                0 => data_valid,
                others => '0'
            );
        end if;
    end process;
end behaviour;
