--====================================--
-- Narayan Shimanoe Lisboa   14600141 --
-- Hugo dos Reis             12544308 --
--====================================--

-- importando bibliotecas.

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

--- ================================== =---
-- declaração da entidade toplevel
entity toplevel is
    port (
        clock, reset   : in std_logic;
        serial_in      : in std_logic;

        -- saídas para os 2 displays.
        display0      : out std_logic_vector(6 downto 0);
        display1      : out std_logic_vector(6 downto 0);

        -- saídas do contador de substituição.
        sub_1_out     : out std_logic;
        sub_2_out     : out std_logic;
        sub_3_out     : out std_logic;
        sub_4_out     : out std_logic;
        sub_5_out     : out std_logic;
        sub_erro_out  : out std_logic
    );
end toplevel;

-- ========================================= --

-- Declaração da arquitetura.
architecture projeto of toplevel is

-- declaraão de componentes que serão utilizados.

    -- Compoenente IP_PLL.
    component ip_pll is
        port (
            refclk      : in std_logic;
            rst         : in std_logic;
            outclk_0    : out std_logic;
            locked      : out std_logic
        );
    end component;

    -- Componente BaudRateGenerator.
    component baudRateGenerator is
        port (
            clock       : in  std_logic;
            reset       : in  std_logic;
            divisor     : in  std_logic_vector(15 downto 0);
            baud_clock  : out std_logic
    );
    end component;

    -- Componente RTC
    component RTC is
        port (
            clock         : in  std_logic;
            reset         : in  std_logic;
            serial_in     : in  std_logic;
            data_valid    : out std_logic;
            parity_error  : out std_logic;
            reg0          : out std_logic_vector(7 downto 0);
            reg1          : out std_logic_vector(7 downto 0)
        );
    end component;

    -- Componente register
    component reg is
        port (
            clock, reset : in std_logic;
            D            : in std_logic_vector(7 downto 0);
            Q            : out std_logic_vector(7 downto 0)
        );
    end component;

    -- Componente sub_counter
    component sub_counter is
        port (
            clock, reset  : in std_logic; -- Clock e reset assíncrono.
            substitution  : in std_logic;
            subs_1        : out std_logic; 
            subs_2        : out std_logic; 
            subs_3        : out std_logic;
            subs_4        : out std_logic; 
            subs_5        : out std_logic; 
            subs_erro     : out std_logic 
        );
    end component;

    -- Componente ascii
    component asciidisp is
        port(
            ascii_in    : in  std_logic_vector(7 downto 0);
            subs6_erro  : in std_logic;
            segment_out : out std_logic_vector(6 downto 0)
        );
    end component;

    -- Declaração de sinais internos:

    --sinais internos de comunicação.
    signal internal_clock  : std_logic;
    signal baud_clock_int  : std_logic;
    signal pll_locked_int  : std_logic;

    -- sinais internos de erro de controle.
    signal internal_data_valid   : std_logic;
    signal sub_erro_int          : std_logic;
    signal internal_parity_error : std_logic;

    -- sinais internos para os registradores
    signal reg0_int, reg1_int : std_logic_vector(7 downto 0);

    -- sinais internos para os ascii.
    signal ascii0_int, ascii1_int : std_logic_vector(7 downto 0);

begin

    clocker: ip_pll
        port map (
                refclk  => clock,
                rst      => reset,
                outclk_0 => internal_clock,
                locked   => pll_locked_int
        );

    baud_gen: baudRateGenerator
        port map (
            clock      => internal_clock,
            reset      => not pll_locked_int,
            divisor    => "0000000000001100", -- 12
            baud_clock => baud_clock_int
        );

    u_RTC : RTC 
        port map (
            clock        => baud_clock_int,
            reset        => reset,
            serial_in    => serial_in,
            data_valid   => internal_data_valid,
            parity_error => internal_parity_error,
            reg0         => reg0_int,
            reg1         => reg1_int
        );

    registrador0 : reg
        port map (
            clock => baud_clock_int,
            reset => reset,
            D     => reg0_int,
            Q     => ascii0_int
        );

    registrador1 : reg
        port map (
            clock => baud_clock_int,
            reset => reset,
            D     => reg1_int,
            Q     => ascii1_int
        );

    sub_ctr : sub_counter
        port map (
            clock        => baud_clock_int,
            reset        => reset,
            substitution => internal_data_valid,
            subs_1       => sub_1_out,
            subs_2       => sub_2_out,
            subs_3       => sub_3_out,
            subs_4       => sub_4_out,
            subs_5       => sub_5_out,
            subs_erro    => sub_erro_int
        );
    
    sub_erro_out <= sub_erro_int;

    display0_inst : asciidisp
        port map (
            ascii_in => ascii0_int,
            subs6_erro => sub_erro_int,
            segment_out => display0
        );
    
    display1_inst : asciidisp
        port map (
            ascii_in => ascii1_int,
            subs6_erro => sub_erro_int,
            segment_out => display1
        );

        
end architecture projeto;
