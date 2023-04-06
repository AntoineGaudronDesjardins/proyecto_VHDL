-- **********************************************************************
-- LIBRERIAS
-- **********************************************************************
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

-- **********************************************************************
-- ENTIDAD     (entradas/salidas, el fichero de simulación no tiene)
-- **********************************************************************
ENTITY test_divisor_frecuencia IS
END    test_divisor_frecuencia;

-- **********************************************************************
-- ARQUITECTURA   (descripción de los estímulos)
-- **********************************************************************
ARCHITECTURE test_divisor_frecuencia_arq OF test_divisor_frecuencia IS
    --Declaración de componentes
    COMPONENT divisor_frecuencia
    port (
        -- ENTRADAS --
        CLK : in std_logic;
        RESET : in std_logic;
        -- SALIDAS
        CLK_SLOW : out std_logic
    );
    END COMPONENT;

    -- Entradas
    SIGNAL CLK_test		: std_logic;
    SIGNAL RESET_test 		: std_logic;
    
    -- Salida
    SIGNAL CLK_SLOW_test  	: std_logic;

    
    -- Internas
    SIGNAL FIN_test:  std_logic := '0' ;       -- Indica fin de simulación. Se pone a '1' al final de la simulacion. 
    					       -- Se utiliza para bloquear el reloj y apreciar mejor el final de la simulación.				       
    
    constant ciclo : time := 10 ns;  -- 100Mhz


BEGIN
    -- ///////////////////////////////////////////////////////////////////////////////
    -- Se crea el componente U1 y se conecta a las señales internas de la arquitectura
    -- ///////////////////////////////////////////////////////////////////////////////
    U1: divisor_frecuencia PORT MAP(
                        CLK 		=> CLK_test,
                        RESET		=> RESET_test,
                        CLK_SLOW	=> CLK_SLOW_test                      
                     );

    GenCLK: process
    begin
        if (FIN_test='1') THEN
            CLK_test<= '0';         WAIT;     -- Bloquea el reloj
        ELSE
            CLK_test<= '1';     wait for ciclo/2;
            CLK_test<= '0';     wait for ciclo/2;
            
        END IF;
    end process GenCLK;

    GenReset: process
    begin
        RESET_test<= '1';     wait for ciclo;     -- Nos situamos en el flanco de bajada del reloj
        RESET_test<= '0';     wait;
    end process GenReset;

    tb: PROCESS
    BEGIN
    	--Inicialización

    		
	
	
	wait;
	
    end process tb;
END test_divisor_frecuencia_arq;


















