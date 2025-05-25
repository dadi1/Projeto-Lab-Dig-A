--====================================--
-- Narayan Shimanoe Lisboa   14600141 --
-- Hugo dos Reis             12544308 --
--====================================--

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity baudRateGenerator is
    port(
        clk      : in  std_logic;
        rst      : in  std_logic;
        divisor  : in  std_logic_vector(15 downto 0);
        baud_clk : out std_logic
    );
end baudRateGenerator;

architecture behaviour of baudRateGenerator is
    signal counter : unsigned(15 downto 0) := (others => '0');
    signal div_val : unsigned(15 downto 0);
    signal clk_out : std_logic := '0';
begin
    div_val <= unsigned(divisor);

    process(clk, rst)
    begin
        if rst = '1' then
            counter <= (others => '0');
            clk_out <= '1';
        elsif rising_edge(clk) then
            if counter = div_val - 1 then
                counter <= (others => '0');
                clk_out <= '1';
            else
                counter <= counter + 1;
                clk_out <= '0';
            end if;
        end if;
    end process;
    
    baud_clk <= clk_out;
end behaviour;
