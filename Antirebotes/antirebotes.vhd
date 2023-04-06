library ieee;
use ieee.std_logic_1164.all;

entity debouncing is
    generic (
    	CICLOS_FILTER	: integer := 5
    );
    
    port (
        -- ENTRADAS --
        CLK : in std_logic;
        RESET : in std_logic;
        BUTTON_IN : in std_logic;
        -- SALIDAS
        BUTTON_OUT : out std_logic
    );
end entity;

architecture arch_debouncing of debouncing is

    -- CODIGO DEL ALUMNO --
    
     TYPE ESTADOS IS (inactivo, activo);
     SIGNAL estado_s, estado_c : ESTADOS;
     
     SIGNAL ciclos_antirebotes : integer := CICLOS_FILTER;
     SIGNAL contador_antirebotes : integer := 0;
begin


	PROCESS (CLK,RESET)
	BEGIN
		IF (RESET='1') THEN                 -- Reset activo a nviel alto
        	    	estado_s  <= inactivo;
        	ELSIF (rising_edge(CLK)) THEN  
			estado_s  <= estado_c;
			IF (estado_s = inactivo) THEN
				IF(BUTTON_IN = '1') THEN
					contador_antirebotes <= contador_antirebotes + 1;
					IF (contador_antirebotes = ciclos_antirebotes) THEN
						contador_antirebotes <= 0;	
					END IF;
				ELSE
					contador_antirebotes <= 0;	
				END IF;	
			END IF;
		END IF;	
	END PROCESS;
    
	PROCESS (estado_s, estado_c,CLK)
	BEGIN
    		CASE estado_s IS
    			WHEN inactivo =>
           			BUTTON_OUT <= '0';
				IF(BUTTON_IN = '1') THEN
					IF (contador_antirebotes = ciclos_antirebotes) THEN
						estado_c <= activo;
					END IF;
				END IF;	
    			WHEN activo =>
    				BUTTON_OUT <= '1';
    				estado_c <= inactivo;
    		END CASE;
      	                                                                  			
    END PROCESS;    
    


end architecture;
    


