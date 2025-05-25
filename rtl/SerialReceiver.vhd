--====================================--
-- Narayan Shimanoe Lisboa - 14600141 --
-- Hugo dos Reis - 12544308           --  
--====================================--

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity SerialReceiver is
    port(
        clk          : in  std_logic;
        rst          : in  std_logic;
        rx_serial    : in  std_logic;
        lcr_config   : in  std_logic_vector(7 downto 0);
        rx_data      : out std_logic_vector(7 downto 0);
        lsr_pe       : out std_logic;
        lsr_dr       : out std_logic
    );
end SerialReceiver;

architecture behaviour of SerialReceiver is
    component ReceiverShiftRegister
        port(
            clk         : in  std_logic;
            rst         : in  std_logic;
            shift_en    : in  std_logic;
            serial_in   : in  std_logic;
            data_out    : out std_logic_vector(7 downto 0);
            bit_count   : in  integer range 0 to 7
        );
    end component;

    component ReceiverTimerControl
        port(
            clk          : in  std_logic;
            rst          : in  std_logic;
            serial_in    : in  std_logic;
            word_length  : in  std_logic_vector(1 downto 0);
            parity_en    : in  std_logic;
            parity_type  : in  std_logic;
            shift_en     : out std_logic;
            bit_count    : out integer range 0 to 7;
            parity_error : out std_logic;
            data_valid   : out std_logic
        );
    end component;

    component LineControlRegister
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
    end component;

    component LineStatusRegister
        port(
            clk          : in  std_logic;
            rst          : in  std_logic;
            data_valid   : in  std_logic;
            parity_error : in  std_logic;
            lsr_out      : out std_logic_vector(7 downto 0)
        );
    end component;

    signal word_length  : std_logic_vector(1 downto 0);
    signal parity_en, parity_type : std_logic;
    signal shift_en, data_valid, parity_error : std_logic;
    signal bit_count : integer range 0 to 7;
    signal internal_data : std_logic_vector(7 downto 0);
    signal lsr_status : std_logic_vector(7 downto 0);
begin
    LCR_inst: LineControlRegister
        port map(
            clk         => clk,
            rst         => rst,
            load        => '1',
            lcr_config  => lcr_config,
            word_length => word_length,
            stop_bits   => open,
            parity_en   => parity_en,
            parity_type => parity_type
        );

    RTC_inst: ReceiverTimerControl
        port map(
            clk          => clk,
            rst          => rst,
            serial_in    => rx_serial,
            word_length  => word_length,
            parity_en    => parity_en,
            parity_type  => parity_type,
            shift_en     => shift_en,
            bit_count    => bit_count,
            parity_error => parity_error,
            data_valid   => data_valid
        );

    RSR_inst: ReceiverShiftRegister
        port map(
            clk         => clk,
            rst         => rst,
            shift_en    => shift_en,
            serial_in   => rx_serial,
            data_out    => internal_data,
            bit_count   => bit_count
        );

    LSR_inst: LineStatusRegister
        port map(
            clk          => clk,
            rst          => rst,
            data_valid   => data_valid,
            parity_error => parity_error,
            lsr_out      => lsr_status
        );

    process(clk, rst)
    begin
        if rst = '1' then
            rx_data <= (others => '0');
        elsif rising_edge(clk) then
            if data_valid = '1' then
                rx_data <= internal_data;
            end if;
        end if;
    end process;

    lsr_pe <= lsr_status(2);
    lsr_dr <= lsr_status(0);
end behaviour;

