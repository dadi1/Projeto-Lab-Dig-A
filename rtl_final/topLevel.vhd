library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity toplevel is
    port (
        clk      : in  std_logic;
        reset    : in  std_logic;
		serial_in    : in  std_logic;

        -- Saídas para os 2 displays
        display0 : out std_logic_vector(6 downto 0);
        display1 : out std_logic_vector(6 downto 0);
		  
		data_valid : out std_logic;
		parity_error : out std_logic;
        
        -- saidas do contador de substituição.
        sub_1        : out std_logic;
        sub_2        : out std_logic;
        sub_3        : out std_logic;
        sub_4        : out std_logic;
        sub_5        : out std_logic;
        sub_erro     : out std_logic
    );
end toplevel;

architecture projeto of toplevel is

    -- Sinais internos para os registradores ASCII
    signal r0, r1: std_logic_vector(7 downto 0);
    signal r0_d, r1_d: std_logic_vector(7 downto 0);


    -- Sinais do clock e comunicacao
    signal internal_clk: std_logic;
    signal baud_clk: std_logic;
    signal pll_locked: std_logic;

    -- Sinais de controle e erro
    signal internal_data_valid: std_logic;
    signal sub_erro : std_logic;

    -- Componente para display de 7 segmentos
    component asciidisp is
        port (
            ascii_in: in std_logic_vector(7 downto 0);
            subs_erro: in std_logic;
            segment_out: out std_logic_vector(6 downto 0)
        );
    end component;

    -- Componente PLL
    component ip_ppl is
        port (
            refclk: in std_logic;
            rst: in std_logic;
            outclk_0: out std_logic;
            locked: out std_logic
        );
    end component ip_ppl;

    -- Gerador de Baud Rate
    component baudRateGenerator is
        port (
            clk: in std_logic;
            rst: in std_logic;
            divisor: in std_logic_vector(15 downto 0);
            baud_clk: out std_logic
        );
    end component baudRateGenerator;

    -- Registrador de 8 bits
    component reg is
        port (
            clk: in std_logic;
            reset: in std_logic;
            D: in std_logic_vector(7 downto 0);
            Q: out std_logic_vector(7 downto 0)
        );
    end component reg;

    -- Contador de Substituicoes
    component sub_counter is
        port (
            clock: in std_logic;
            reset: in std_logic;
            substitution: in std_logic;
            subs_1: out std_logic;
            subs_2: out std_logic;
            subs_3: out std_logic;
            subs_4: out std_logic;
            subs_5: out std_logic;
            subs_erro: out std_logic
        );
    end component;

     component RTC is
         port map (
             clock      : in  std_logic;
             reset      : in  std_logic;
             serial_in  : in  std_logic;
             data_valid : out std_logic;
             parity_error : out std_logic;
             reg0       : out std_logic_vector(7 downto 0);
             reg1       : out std_logic_vector(7 downto 0)
       );
    end component;

begin

    -- Geracao de Clock com PLL
    clocker: ip_ppl
        port map(
            refclk   => clk,
            rst      => reset,
            outclk_0 => internal_clk,
            locked   => pll_locked
        );

    -- Gerador de Baud Rate para a comunicacao serial
    baud_gen: baudRateGenerator
        port map(
            clk     => internal_clk,
            rst     => not pll_locked, -- Reset ate o PLL estabilizar
            divisor => "0000000000001100", -- 12
            baud_clk => baud_clk
        );

    -- Receptor Serial (UART)
    u_RTC: entity work.RTC
        port map(
            clock        => baud_clk,
            reset        => reset,
            serial_in    => serial_in,
            data_valid   => internal_data_valid,
            parity_error => internal_parity_error,
            reg0         => r0_d,
            reg1         => r1_d
        );

    -- Registradores para armazenar os bytes recebidos
    registrador0: reg
        port map(clk => clk, reset => reset, D => r0_d, Q => r0);

    registrador1: reg
        port map(clk => clk, reset => reset, D => r1_d, Q => r1);

    -- Contador de bytes validos recebidos
    sub_ctr: sub_counter
        port map(
            clock        => clk,
            reset        => reset, -- CORRIGIDO: usa o reset principal
            substitution => internal_data_valid, -- CORRIGIDO: conta quando um dado valido eh recebido
            subs_1       => sub_1,
            subs_2       => sub_2,
            subs_3       => sub_3,
            subs_4       => sub_4,
            subs_5       => sub_5,
            subs_erro    => sub_erro -- A saida de erro do contador vai para a porta 'erro'
        );
    
        subs_erro <= sub_erro

    -- Conversores de ASCII para Display de 7 segmentos
    disp0: asciidisp
        port map(
            ascii_in    => r0, -- CORRIGIDO: conecta a saida do registrador 0
            subs_erro   => sub_erro, -- CORRIGIDO: indica erro de paridade no display
            segment_out => d_s0
        );

    disp1: asciidisp
        port map(
            ascii_in    => r1, -- CORRIGIDO: conecta a saida do registrador 1
            subs_erro   => sub_erro, -- CORRIGIDO: indica erro de paridade no display
            segment_out => d_s1
        );

    -- Conexoes das saidas do toplevel
    display0     <= d_s0;
    display1     <= d_s1;
    data_valid   <= internal_data_valid;
    parity_error <= internal_parity_error;
    sub_erro    <= subs_erro


end architecture projeto;