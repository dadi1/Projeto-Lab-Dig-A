--====================================--
-- Narayan Shimanoe Lisboa - 14600141 --
-- Hugo dos Reis - 12544308           --  
--====================================--

-- importando bibliotecas.

library IEEE;
library IEEE.std_logic_1164.all;
library IEEE.numeric_std.all;

--- ================================== =---
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
-- ====================================---

-- =====================================--
-- implementação da arquitetura.
architecture comportamental of sub_counter is

    -- implemntação do estados.
    type estado_t is (IDLE, SUB_1, SUB_2, SUB_3, SUB_4, SUB_5, ERRO);
    signal  PE, EA :  estado_t;

    -- processo de clock e mudança de estado.
begin 
    process(clock, reset)
    begin
        if reset = '1' then -- reset Assíncrono.
            EA <= IDLE;
        elsif (rising_edge(clock)) then
            EA <= PE;
        end if
    end process;
    
    -- processo da Máquina de estados.
    process(EA, substitution)
    begin
        PE <= EA; -- Comportamento padrão: manter o estado atual.

        if substitution = '1' then -- se houver substituição.
            case EA is

                -- primeira substituição.
                when IDLE =>
                    PE <= SUB_1;

                -- segunda substituição.
                when SUB_1 =>
                    PE <= SUB_2;
                
                -- terceira substituição.
                when SUB_2 =>
                    PE <= SUB_3;

                -- quarta substituição.
                when SUB_3 =>
                    PE <= SUB_4;

                -- quinta substituição.
                when SUB_4 =>
                    PE <= SUB_5;

                -- erro (mais uma substituição depois de 5)
                when SUB_5 =>
                    PE <= ERRO;

                when ERRO =>
                    PE <= ERRO; -- permanece no estado.
            end case;
        end if;
    end process;

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