library ieee;
use ieee.std_logic_1164.all;

entity divisor_frecuencia is
    generic(
    	N_MAX : integer := 50000000
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
    signal contador : integer range 0 to N_MAX - 1 := 0;
    
begin

    process (CLK, RESET)
    begin
        -- RESET ASINCRONO A NIVEL ALTO
        if (RESET = '1') then
            contador <= 0;
            CLK_SLOW <= '0';
        elsif (rising_edge(CLK)) then
            if (contador = N_MAX - 1) then
                CLK_SLOW <= '1';
                contador <= 0;
            else
                CLK_SLOW <= '0';
                contador <= contador + 1;
            end if;
        end if;
    end process;

end architecture;
