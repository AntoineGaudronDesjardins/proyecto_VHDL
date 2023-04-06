-- **********************************************************************
-- LIBRERIAS
-- **********************************************************************
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

-- **********************************************************************
-- ENTIDAD     (entradas/salidas, el fichero de simulación no tiene)
-- **********************************************************************
ENTITY test_antirebotes IS
END    test_antirebotes;

-- **********************************************************************
-- ARQUITECTURA   (descripción de los estímulos)
-- **********************************************************************
ARCHITECTURE test_antirebotes_arq OF test_antirebotes IS
    --Declaración de componentes
    COMPONENT debouncing
    port (
        -- ENTRADAS --
        CLK : in std_logic;
        RESET : in std_logic;
        BUTTON_IN : in std_logic;
        -- SALIDAS
        BUTTON_OUT : out std_logic
    );
    END COMPONENT;

    -- Entradas
    SIGNAL CLK_test		: std_logic;
    SIGNAL RESET_test 		: std_logic;
    SIGNAL BUTTON_IN_test	: std_logic;
    
    -- Salida
    SIGNAL BUTTON_OUT_test  	: std_logic;

    
    -- Internas
    SIGNAL FIN_test:  std_logic := '0' ;       -- Indica fin de simulación. Se pone a '1' al final de la simulacion. 
    					       -- Se utiliza para bloquear el reloj y apreciar mejor el final de la simulación.				       
    
    constant ciclo : time := 10 ns;  -- 100Mhz


BEGIN
    -- ///////////////////////////////////////////////////////////////////////////////
    -- Se crea el componente U1 y se conecta a las señales internas de la arquitectura
    -- ///////////////////////////////////////////////////////////////////////////////
    U1: debouncing PORT MAP(
                        CLK 		=> CLK_test,
                        RESET		=> RESET_test,
                        BUTTON_IN	=> BUTTON_IN_test,
                        BUTTON_OUT	=> BUTTON_OUT_test                     
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
	BUTTON_IN_test <= '0';
	
	wait for ciclo*3;
	
	BUTTON_IN_test <= '1';
	
	wait for ciclo*3;
    		
	BUTTON_IN_test <= '0';
	
	wait for ciclo*3;

	BUTTON_IN_test <= '1';
	
	wait for ciclo*6;
    		
	BUTTON_IN_test <= '0';
	
	wait for ciclo*3;
		
	wait;
	
    end process tb;
END test_antirebotes_arq;



















