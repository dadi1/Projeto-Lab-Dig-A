--====================================--
-- Narayan Shimanoe Lisboa   14600141 --
-- Hugo dos Reis             12544308 --
--====================================--
entity LineControlRegister is
    port(
        clk         : in  std_logic;
        rst         : in  std_logic;
        load        : in  std_logic;
        lcr_config  : in  std_logic_vector(7 downto 0);
        word_length : out std_logic_vector(1 downto 0);
        stop_bits   : out std_logic;
        parity_en   : out std_logic;
        parity_type : out std_logic
    );
end LineControlRegister;

architecture behaviour of LineControlRegister is
    signal reg : std_logic_vector(7 downto 0);
begin
    process(clk, rst)
    begin
        if rst = '1' then
            reg <= (others => '0');
        elsif rising_edge(clk) then
            if load = '1' then
                reg <= lcr_config;
            end if;
        end if;
    end process;

    word_length <= reg(1 downto 0);
    stop_bits   <= reg(2);
    parity_en   <= reg(3);
    parity_type <= reg(4);
end behaviour;