library ieee;
use ieee.std_logic_1164.all;

entity divisor_frecuencia is
    generic(
    	N_MAX : integer := 5000000 --CAMBIAR A 50.000.000
    );
    port (
        -- ENTRADAS --
        CLK : in std_logic;
        RESET : in std_logic;
        -- SALIDAS
        CLK_SLOW : out std_logic
    );
end entity;

architecture arch_divisor_frecuencia of divisor_frecuencia is

    -- CODIGO DEL ALUMNO --
    
    SIGNAL contador : integer range 0 to N_MAX - 1 := 0;
    SIGNAL senal : std_logic := '1';
    
begin

    PROCESS (CLK,RESET)
    BEGIN
        IF (RESET='1') THEN                 -- Reset activo a nviel alto
            contador <= 0;
            CLK_SLOW <= '0';
        ELSIF (rising_edge(CLK)) THEN  
            contador <= contador + 1;
            IF (contador = N_MAX - 1) THEN
            	senal <= NOT senal;
            	CLK_SLOW <= senal;
            	contador <= 0;
            END IF;
       END IF;
    END PROCESS;
    


end architecture;
    






