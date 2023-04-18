library ieee;
use ieee.std_logic_1164.all;

entity divisor_frecuencia is
    generic(
    	DIVISOR : integer := 50000000
    );
    port (
        -- ENTRADAS --
        CLK     : in std_logic;
        RESET   : in std_logic;
        -- SALIDAS --
        CLK_SLOW : out std_logic := '0'
    );
end entity;

architecture arch_divisor_frecuencia of divisor_frecuencia is

    -- CODIGO DEL ALUMNO --
    signal contador        : integer range 0 to DIVISOR - 1 := 0;
    signal contador_futuro : integer range 0 to DIVISOR - 1 := 0;
    
begin

    -- PROCESO DE SINCRONIZACION
    process (CLK, RESET)
    begin
        -- RESET ASINCRONO A NIVEL ALTO
        if (RESET = '1') then
            contador <= 0;
        elsif (rising_edge(CLK)) then
            contador <= contador_futuro;
        end if;
    end process;
    
    -- PROCESO COMBINACIONAL
    process (contador)
    begin
        if (contador = DIVISOR - 1) then
            contador_futuro <= 0;
            CLK_SLOW <= '1';
        else
            contador_futuro <= contador + 1;
            CLK_SLOW <= '0';
        end if;
    end process;

end architecture;
