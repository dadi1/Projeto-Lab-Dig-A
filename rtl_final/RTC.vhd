library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity RTC is
    Port (
        clock         : in  std_logic;
        reset         : in  std_logic;
        serial_in     : in  std_logic;
        data_valid    : out std_logic;
        parity_error  : out std_logic;

        -- Saídas dos 2 registradores de memória
        reg0  : out std_logic_vector(7 downto 0);
        reg1  : out std_logic_vector(7 downto 0)
    );
end RTC;

architecture Behavioral of RTC is
    type state_type is (IDLE, START_BIT, DATA_BITS, PARITY, STOP_BIT);
    signal state : state_type := IDLE;

    signal shift_reg : std_logic_vector(7 downto 0) := (others => '0');
    signal bit_counter : integer range 0 to 7 := 0;
    signal sample_count : integer range 0 to 15 := 0;

    -- Internamente fixamos os parâmetros da LCR:
    constant num_bits : integer := 8;
    constant parity_enabled : std_logic := '1';
    constant parity_even : std_logic := '1';

    signal parity_calc : std_logic := '0';

    -- Buffer de 20 registradores
    type reg_array is array(0 to 1) of std_logic_vector(7 downto 0);
    signal mem : reg_array := (others => (others => '0'));
    signal write_index : integer range 0 to 1 := 0;

begin

    -- Estado de recepção serial
    process(clock, reset)
    begin
        if reset = '1' then
            state <= IDLE;
            bit_counter <= 0;
            sample_count <= 0;
            parity_error <= '0';
            data_valid <= '0';
            parity_calc <= '0';
            write_index <= 0;
				mem <= (others => (others => '0'));
        elsif rising_edge(clock) then
            data_valid <= '0';

            case state is
                when IDLE =>
                    if serial_in = '0' then
                        state <= START_BIT;
                        sample_count <= 7;
                        parity_calc <= '0';
                    end if;

                when START_BIT =>
                    if sample_count = 0 then
                        shift_reg <= (others => '0');
                        state <= DATA_BITS;
                        sample_count <= 15;
                        bit_counter <= 0;
                    else
                        sample_count <= sample_count - 1;
                    end if;

                when DATA_BITS =>
                    if sample_count = 8 then
                        shift_reg <= serial_in & shift_reg(7 downto 1);
                        parity_calc <= parity_calc xor serial_in;
                    end if;

                    if sample_count = 0 then
                        sample_count <= 15;
                        if bit_counter = num_bits - 1 then
                            if parity_enabled = '1' then
                                state <= PARITY;
                            else
                                state <= STOP_BIT;
                            end if;
                        else
                            bit_counter <= bit_counter + 1;
                        end if;
                    else
                        sample_count <= sample_count - 1;
                    end if;

                when PARITY =>
                    if sample_count = 8 then
                        if parity_even = '1' then
                            parity_error <= parity_calc xor serial_in;
                        else
                            parity_error <= not (parity_calc xor serial_in);
                        end if;
                    end if;

                    if sample_count = 0 then
                        state <= STOP_BIT;
                        sample_count <= 15;
                    else
                        sample_count <= sample_count - 1;
                    end if;

                when STOP_BIT =>
                    if sample_count = 0 then
                        state <= IDLE;
                        data_valid <= '1';
                        -- Salva no próximo registrador
			-- Salva o caractere recebido
			mem(write_index) <= shift_reg;

			    if write_index = 1 then
				write_index <= 0;
			    else
				write_index <= write_index + 1;
			    end if;

                        --mem(write_index) <= shift_reg;
                        --if write_index = 1 then
                        --    write_index <= 0;
                        --else
                        --    write_index <= write_index + 1;
                        --end if;
                    else
                        sample_count <= sample_count - 1;
                    end if;
            end case;
        end if;
    end process;

    -- Saídas dos registradores
    reg0  <= mem(0);  reg1  <= mem(1);

end Behavioral;

