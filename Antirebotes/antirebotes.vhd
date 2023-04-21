library ieee;
use ieee.std_logic_1164.all;

entity debouncing is
    generic (
        CICLOS_FILTRO : integer := 5
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
    signal contador, contador_futuro : integer := 0;

begin

    -- PROCESO DE SINCRONIZACION
    process (CLK, RESET)
    begin
        -- RESET ASINCRONO A NIVEL ALTO
        if (RESET = '1') then
            contador <= 0;
            actual <= inactivo;
        elsif (rising_edge(CLK)) then
            -- ACTUALIZACION DEL ESTADO ACTUAL (estado y contador)
            contador <= contador_futuro;
            actual <= futuro;
        end if;
    end process;
    
    -- PROCESO COMBINACIONAL
    process (BUTTON_IN, actual, contador)
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
                    contador_futuro <= 0;
                
                when filtro =>
                    contador_futuro <= contador + 1;
                    if (contador + 1 = CICLOS_FILTRO - 1) then
                        futuro <= activo;
                    end if;
                
                when activo =>
                    contador_futuro <= 0;
                    futuro <= espera;
                
                when espera =>
                    futuro <= espera;
                
                when others =>
                    contador_futuro <= 0;
                    futuro <= inactivo;

            end case;
        else
            contador_futuro <= 0;
            futuro <= inactivo;
        end if;
    end process;

end architecture;
