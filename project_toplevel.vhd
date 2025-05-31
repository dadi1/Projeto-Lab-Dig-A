--====================================--
-- Narayan Shimanoe Lisboa   14600141 --
-- Hugo dos Reis             12544308 --
--====================================--

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity exp06 is
    port(
        clk_50MHz    : in  std_logic;
        global_reset : in  std_logic;
        serial_rx    : in  std_logic;
        lcr_config   : in  std_logic_vector(7 downto 0);
        --rx_data_out  : out std_logic_vector(7 downto 0); --saida paralela do valor recebido
        lsr_pe       : out std_logic;
        lsr_dr       : out std_logic;
        segment_out  : out std_logic_vector(6 downto 0);

        -- saidas do contador de substituição.
        sub_1        : out std_logic;
        sub_2        : out std_logic;
        sub_3        : out std_logic;
        sub_4        : out std_logic;
        sub_5        : out std_logic;
        sub_erro     : out std_logic
    );
end exp06;

architecture behaviour of exp06 is
    component ip_pll
        port (
            refclk   : in  std_logic;
            rst      : in  std_logic;
            outclk_0 : out std_logic;
            locked   : out std_logic
        );
    end component;

    component baudRateGenerator
        port(
            clk      : in  std_logic;
            rst      : in  std_logic;
            divisor  : in  std_logic_vector(15 downto 0);
            baud_clk : out std_logic
        );
    end component;

    component SerialReceiver
        port(
            clk        : in  std_logic;
            rst        : in  std_logic;
            rx_serial  : in  std_logic;
            lcr_config : in  std_logic_vector(7 downto 0);
            rx_data    : out std_logic_vector(7 downto 0);
            lsr_pe     : out std_logic;
            lsr_dr     : out std_logic
        );
    end component;

    component ascii
        port(
            ascii_in    : in  std_logic_vector(7 downto 0);
            segment_out : out std_logic_vector(6 downto 0)
        );
    end component;

    component sub_counter
        port (
            clock         : in  std_logic;
            reset         : in  std_logic;
            substitution  : in  std_logic;
            subs_1        : out std_logic;
            subs_2        : out std_logic;
            subs_3        : out std_logic;
            subs_4        : out std_logic;
            subs_5        : out std_logic;
            subs_erro     : out std_logic
        );
    end component;

    signal clk_1p8432MHz : std_logic;
    signal baud_clk      : std_logic;
    signal rx_data       : std_logic_vector(7 downto 0);
    signal lsr_dr_int    : std_logic;
    
    constant BAUD_DIVISOR : std_logic_vector(15 downto 0) := x"000C";
begin
    pll_inst: ip_pll
        port map (
            refclk   => clk_50MHz,
            rst      => global_reset,
            outclk_0 => clk_1p8432MHz,
            locked   => open
        );

    brg_inst: baudRateGenerator
        port map(
            clk      => clk_1p8432MHz,
            rst      => global_reset,
            divisor  => BAUD_DIVISOR,
            baud_clk => baud_clk
        );

    receiver_inst: SerialReceiver
        port map(
            clk        => baud_clk,
            rst        => global_reset,
            rx_serial  => serial_rx,
            lcr_config => lcr_config,
            rx_data    => rx_data,
            lsr_pe     => lsr_pe,
            lsr_dr     => lsr_dr_int
        );

    lsr_dr <= lsr_dr_int;

    sub_ctr: sub_counter
        port map(
            clock        => baud_clk,      -- ou baud_clk, conforme desejar
            reset        => global_reset,
            substitution => lsr_dr_int,     -- conta cada byte pronto
            subs_1        => sub_1,
            subs_2        => sub_2,
            subs_3        => sub_3,
            subs_4        => sub_4,
            subs_5        => sub_5,
            subs_erro     => erro
        );


    display_conv: ascii
        port map(
            ascii_in    => rx_data,
            segment_out => segment_out
        );

    --rx_data_out <= rx_data;
end behaviour;