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
    PORT (
        -- ENTRADAS --
        CLK         : IN std_logic;
        RESET       : IN std_logic;
        BUTTON_IN   : IN std_logic;
        -- SALIDAS --
        BUTTON_OUT  : OUT std_logic
    );
    END COMPONENT;

    -- Entradas
    SIGNAL CLK_test		    : std_logic;
    SIGNAL RESET_test 		: std_logic;
    SIGNAL BUTTON_IN_test	: std_logic;
    
    -- Salida
    SIGNAL BUTTON_OUT_test  : std_logic;

    
    -- Internas
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

    GenCLK: PROCESS
    BEGIN
        CLK_test <= '1';     WAIT FOR ciclo/2;
        CLK_test <= '0';     WAIT FOR ciclo/2;
    END PROCESS GenCLK;

    GenReset: PROCESS
    BEGIN
        RESET_test <= '1';     WAIT FOR ciclo;     -- Nos situamos en el flanco de subida del reloj
        RESET_test <= '0';     WAIT;
    END PROCESS GenReset;

    tb: PROCESS
    BEGIN
    	--Inicialización
        BUTTON_IN_test <= '0';
        
        WAIT FOR ciclo*3;
        
        BUTTON_IN_test <= '1';
        
        WAIT FOR ciclo*3;
                
        BUTTON_IN_test <= '0';
        
        WAIT FOR ciclo*3;

        BUTTON_IN_test <= '1';
        
        WAIT FOR ciclo*30;
                
        BUTTON_IN_test <= '0';
        
        WAIT FOR ciclo*3;

        BUTTON_IN_test <= '1';
        
        WAIT FOR ciclo*10;
                
        BUTTON_IN_test <= '0';
        
        WAIT FOR ciclo*3;            
        WAIT;
	
    END PROCESS tb;
END test_antirebotes_arq;

