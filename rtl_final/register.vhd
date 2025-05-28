--====================================--
-- Narayan Shimanoe Lisboa   14600141 --
-- Hugo dos Reis             12544308 --
--====================================--

-- importando bibliotecas.

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

--- ================================== =---
entity reg is
    Port(
        clock, reset : in std_logic;
        D          : in std_logic_vector(7 downto 0);
        Q          : out std_logic_vector(7 downto 0)
    );
end reg;

architecture Behavioral of reg is
    signal register : std_logic_vector(7 downto 0);
begin
    process(clock, reset)
    begin
        if reset = '1' then
            reg <= (others => '0');
        elsif rising_edge(clock) then
            reg <= D;
        end if;
    end process;

    Q <= reg;
end Behavioral;