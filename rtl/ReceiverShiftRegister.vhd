--====================================--
-- Narayan Shimanoe Lisboa   14600141 --
-- Hugo dos Reis             12544308 --
--====================================--

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity ReceiverTimerControl is
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
end ReceiverTimerControl;



architecture behaviour of ReceiverTimerControl is
    type state_type is (IDLE, START, DATA, PARITY, STOP, VALIDATE);
    signal state : state_type := IDLE;
    signal next_state : state_type := IDLE;
    signal bit_counter : integer range 0 to 7 := 0;
    signal sample_count : integer range 0 to 15 := 0;
    signal parity_calc : std_logic := '0';
    signal num_bits : integer range 5 to 8;
    signal internal_shift_en : std_logic := '0';
    signal internal_parity_error : std_logic := '0';
    signal internal_data_valid : std_logic := '0';
begin
    num_bits <= 5 when word_length = "00" else
                6 when word_length = "01" else
                7 when word_length = "10" else
                8;

    -- Combinational process for next state logic
    process(state, serial_in, sample_count, bit_counter, num_bits, parity_en)
    begin
        next_state <= state; -- default to current state
       
        case state is
            when IDLE =>
					
                if serial_in = '0' then
                    next_state <= START;
                end if;
           
            when START =>
                if sample_count = 0 then
                    next_state <= DATA;
                end if;
           
            when DATA =>
                if sample_count = 0 then
                    if bit_counter = num_bits - 1 then
                        if parity_en = '1' then
                            next_state <= PARITY;
                        else
                            next_state <= STOP;
                        end if;
                    end if;
                end if;
           
            when PARITY =>
                if sample_count = 0 then
                    next_state <= STOP;
                end if;
           
            when STOP =>
                if sample_count = 0 then
                    next_state <= VALIDATE;
                end if;
           
            when VALIDATE =>
                next_state <= IDLE;
        end case;
    end process;

    -- Sequential process
    process(clk, rst)
    begin
        if rst = '1' then
            state <= IDLE;
            bit_counter <= 0;
            sample_count <= 0;
            parity_calc <= '0';
            internal_shift_en <= '0';
            internal_parity_error <= '0';
            internal_data_valid <= '0';
        elsif rising_edge(clk) then
            state <= next_state;
           
            -- Default outputs
            internal_shift_en <= '0';
            internal_data_valid <= '0';
           
            -- Sample counter logic
            if state = IDLE then
						internal_shift_en <= '0';
                sample_count <= 7;
            elsif sample_count = 0 then
                sample_count <= 15;
            else
                sample_count <= sample_count - 1;
            end if;
           
            -- Bit counter logic
            if state = START and sample_count = 0 then
                bit_counter <= 0;
            elsif state = DATA and sample_count = 0 and bit_counter < num_bits - 1 then
                bit_counter <= bit_counter + 1;
            end if;
           
            -- Shift enable and parity calculation
            if state = DATA and sample_count = 8 then
                internal_shift_en <= '1';
                parity_calc <= parity_calc xor serial_in;
            end if;
           
            -- Parity check
            if state = PARITY and sample_count = 8 theN
				internal_shift_en <= '0';
                if (parity_type = '0') then
                    internal_parity_error <= parity_calc xor serial_in;
                else
                    internal_parity_error <= not (parity_calc xor serial_in);
                end if;
            end if;
           
            -- Data valid
            if state = VALIDATE then
                internal_data_valid <= '1';
                parity_calc <= '0'; -- Reset parity calculation
            end if;
        end if;
    end process;
   
    -- Connect internal signals to outputs
    shift_en <= internal_shift_en;
    parity_error <= internal_parity_error;
    data_valid <= internal_data_valid;
    bit_count <= bit_counter;
end behaviour;