--====================================--
-- Narayan Shimanoe Lisboa - 14600141 --
-- Hugo dos Reis - 12544308           --  
--====================================--

-- importando bibliotecas.

library IEEE;
library IEEE.std_logic_1164.all;
library IEEE.numeric_std.all;

--- Declaração da da entidade counter ---

entity sub_counter is
    port (
        clock, reset : in std_logic; -- Clock e reset assíncrono.
        substitution : in std_logic;
        -- 0 : enquanto substituição não for feito.
        -- 1 : quando uma substituição for feita.

        -- sinais de saida para o número de substituição feitos
        sub_1        : out std_logic; -- primeira substituição.
        sub_2        : out std_logic; -- segunda substituição.
        sub_3        : out std_logic; -- terceira substituição.
        sub_4        : out std_logic; -- quarta substituição.
        sub_5        : out std_logic; -- quinta substituição.
        -- sinal de saida para ERRO
        erro         : out std_logic; -- saida de erro.
    );
end sub_counter; -- Fim da declaração da entidade.

-- implementação da arquitetura.
architecture comportamental of sub_counter is
    type estado_t is (IDLE, SUB_1, SUB_2, SUB_3, SUB_4, SUB_5, ERRO);
    signal  PE, EA, :  estado_t;
begin 
    process(clock, reset)
        if reset = '1' then -- reset Assíncrono.
            EA <= IDLE;
        elsif (rising_edge(clock)) then
            EA <= PE;
        end if
    end process;
    
    -- Máquina de estados.
    PE <=
        SUB_1 when EA = IDLE and substitution = '1' else
        SUB_2 when EA = SUB_1 and substitution = '1' else
        SUB_3 when EA = SUB_2 and substitution = '1' else
        SUB_4 when EA = SUB_3 and substitution = '1' else
        SUB_5 when EA = SUB_4 and substitution = '1' else
        ERRO when EA = SUB_5 and substitution = '1' else
        ERRO;
        
    -- CONTROLE DOS LED'S.

    sub_1 <=
        '1' when EA = SUB_1 or EA = SUB_2 or EA = SUB_3 or EA = SUB_4 or EA = SUB_5 or ERRO else
        '0';
    sub_2 <= '1' when EA = SUB_2 or EA = SUB_3 or EA = SUB_4 or EA = SUB_5 or ERRO else
        '0';
    sub_3 <= '1' when EA = SUB_3 or EA = SUB_4 or EA = SUB_5 or ERRO else
        '0';
    sub_4 <= '1' when EA = SUB_4 or EA = SUB_5 or ERRO else
        '0';
    sub_5 <= '1' when EA = SUB_5 or EA = ERRO else
        '0';
    erro <= '1' when EA = ERRO else
        '0';

end comportamental; -- fim do comportamental.