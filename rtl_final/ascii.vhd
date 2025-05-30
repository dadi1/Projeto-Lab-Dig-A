--====================================--
-- Narayan Shimanoe Lisboa   14600141 --
-- Hugo dos Reis             12544308 --
--====================================--
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity asciidisp is
    port(
        ascii_in    : in  std_logic_vector(7 downto 0);
        subs6_erro  : in std_logic;
        segment_out : out std_logic_vector(6 downto 0)
    );
end asciidisp;

architecture behaviour of asciidisp is 
begin
    process(ascii_in, subs_erro)
    begin
        if subs6_erro = '0' then
            case ascii_in(7 downto 0) is
                when "00110000" => segment_out <= NOT"0111111"; -- 0
                when "00110001" => segment_out <= NOT"0000110"; -- 1
                when "00110010" => segment_out <= NOT"1011011"; -- 2
                when "00110011" => segment_out <= NOT"1001111"; -- 3
                when "00110100" => segment_out <= NOT"1100110"; -- 4
                when "00110101" => segment_out <= NOT"1101101"; -- 5
                when "00110110" => segment_out <= NOT"1111101"; -- 6
                when "00110111" => segment_out <= NOT"0000111"; -- 7
                when "00111000" => segment_out <= NOT"1111111"; -- 8
                when "00111001" => segment_out <= NOT"1101111"; -- 9
                when others => segment_out <= not"0000000";
            end case;
        end if;
    end process;
end behaviour;