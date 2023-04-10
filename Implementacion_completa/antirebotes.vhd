library ieee;
use ieee.std_logic_1164.all;

entity debouncing is
    generic (
        CICLOS_FILTER : integer := 5
    );
    port (
        -- ENTRADAS --
        CLK        : in std_logic;
        RESET      : in std_logic;
        BUTTON_IN  : in std_logic;
        -- SALIDAS --
        BUTTON_OUT : out std_logic
    );
end entity;

architecture arch_debouncing of debouncing is

    -- CODIGO DEL ALUMNO --
    type ESTADOS is (inactivo, filtro, activo, espera);
    signal actual, futuro : ESTADOS := inactivo;
    
    signal ciclos_antirebotes   : integer := CICLOS_FILTER;
    signal contador_antirebotes : integer := 0;

begin

    -- PROCESO DE SINCRONIZACION
    process (CLK)
    begin
        if (rising_edge(CLK)) then
            -- RESET SINCRONO A NIVEL ALTO
            if (RESET = '1') then
                contador_antirebotes <= 0;
                actual <= inactivo;
            else
                -- ACTUALIZACION DEL ESTADO ACTUAL (estado y contador)
                actual <= futuro;
                if (futuro = filtro) then
                    contador_antirebotes <= contador_antirebotes + 1;
                else
                    contador_antirebotes <= 0;
                end if;
            end if;
        end if;
    end process;
    
    -- PROCESO COMBINACIONAL
    process (BUTTON_IN, actual, contador_antirebotes)
    begin
        -- PROCESO COMBINACIONAL DE SALIDA
        if (actual = activo) then
            BUTTON_OUT <= '1';
        else
            BUTTON_OUT <= '0';
        end if;
        
        -- PROCESO COMBINACIONAL DE ENTRADA
        if (BUTTON_IN = '1') then
            case actual is
                when inactivo =>
                    futuro <= filtro;
                
                when filtro =>
                    if (contador_antirebotes = ciclos_antirebotes - 1) then
                        futuro <= activo;
                    end if;
                
                when activo =>
                    futuro <= espera;
                
                when espera =>
                    futuro <= espera;
            end case;
        else
            futuro <= inactivo;
        end if;
    end process;

end architecture;
