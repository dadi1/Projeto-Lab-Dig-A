--====================================--
-- Narayan Shimanoe Lisboa   14600141 --
-- Hugo dos Reis             12544308 --
--====================================--

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity baudRateGenerator is
    port(
        clock       : in  std_logic;
        reset       : in  std_logic;
        divisor     : in  std_logic_vector(15 downto 0);
        baud_clock  : out std_logic
    );
end baudRateGenerator;

architecture behaviour of baudRateGenerator is
    signal counter : unsigned(15 downto 0) := (others => '0');
    signal div_val : unsigned(15 downto 0);
    signal clock_out : std_logic := '0';
begin
    div_val <= unsigned(divisor);

    process(clock, reset)
    begin
        if reset = '1' then
            counter <= (others => '0');
            clock_out <= '1';
        elsif rising_edge(clock) then
            if counter = div_val - 1 then
                counter <= (others => '0');
                clock_out <= '1';
            else
                counter <= counter + 1;
                clock_out <= '0';
            end if;
        end if;
    end process;
    
    baud_clock <= clock_out;
end behaviour;
