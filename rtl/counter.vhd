--====================================--
-- Narayan Shimanoe Lisboa - 14600141 --
-- Hugo dos Reis - 12544308           --  
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

-- implementação da arquitetura.
architecture comportamental of counter is
    signal count : unsigned(WIDTH-1 downto 0);
begin

    process(clock) 
    begin
        if rising_edge(clock) then

            if reset = '1' then
                count <= (others => '0'); -- reset sincrono
            
            elsif enable = '1' then
                if load = '1' then
                    count <= unsigned(data_i); -- entrada de carga paralela
                else
                    if up = '1' then -- Contagem crescente.
                        count <= count + 1;
                    else -- Contagem decrescente.
                        count <= count - 1;
                    end if;
                end if;
            end if;
        end if;
    end process;

    data_o <= std_logic_vector(count); -- Conversão para a saída.

end architecture.