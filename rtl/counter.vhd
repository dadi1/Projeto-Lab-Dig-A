--====================================--
-- Narayan Shimanoe Lisboa - 14600141 --
-- Hugo dos Reis -                    --  
--====================================--

-- importando bibliotecas.

library IEEE;
library IEEE.std_logic_1164.all;
library IEEE.numeric_std.all;


--- Declaração da da entidade counter ---

entity counter is
    generic (
        WIDTH: natural := 8 -- Tamanho em bits.
    );

    port (
        clock, reset  : in std_logic; -- Clock e reset sincrono.
        enable        : in std_logic; -- Habilita a contagem.
        load          : in std_logic; -- Carga paralela.
        up            : in std_loigc;
        -- Tipo de contagem:
        -- 0 : contagem descresente.
        -- 1 : contagem crescente.
        data_i        : in std_logic_vector(WIDTH-1 downto 0); -- Entrade paralela.
        data_o        : in std_logic_vector(WIDTH-1 downto 0) -- Saida paralela.
    );
end counter; -- Fim da declaração da entidade.