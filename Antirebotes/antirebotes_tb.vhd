-- **********************************************************************
-- LIBRERIAS
-- **********************************************************************
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

-- **********************************************************************
-- ENTIDAD     (entradas/salidas, el fichero de simulaci�n no tiene)
-- **********************************************************************
ENTITY test_antirebotes IS
END    test_antirebotes;

-- **********************************************************************
-- ARQUITECTURA   (descripci�n de los est�mulos)
-- **********************************************************************
ARCHITECTURE test_antirebotes_arq OF test_antirebotes IS
    --Declaraci�n de componentes
    COMPONENT debouncing
    GENERIC (
        CICLOS_FILTRO : integer := 5
    );
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
    -- Se crea el componente U1 y se conecta a las se�ales internas de la arquitectura
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
        -- RESET inicial
        RESET_test <= '1';     WAIT FOR ciclo*3/4;
        RESET_test <= '0';     WAIT FOR 31*ciclo;
        -- RESET de interrupcion
        RESET_test <= '1';     WAIT FOR ciclo;
        RESET_test <= '0';     WAIT;
    END PROCESS GenReset;

    tb: PROCESS
    BEGIN
        -- **********************************************************************
        -- Escenario de comportamiento normal
        -- **********************************************************************
    	-- Inicializaci�n
        BUTTON_IN_test <= '0';

        WAIT FOR ciclo*3;
        
        -- Pulso corto : BUTTON_IN se pone a nivel alto 3 ciclos => filtrado
        BUTTON_IN_test <= '1';
        WAIT FOR ciclo*3;
        BUTTON_IN_test <= '0';
        
        WAIT FOR ciclo*3;

        -- Pulso largo : BUTTON_IN se pone a nivel alto 7 ciclos > 5 => pasa la senal durante un ciclo
        BUTTON_IN_test <= '1';
        WAIT FOR ciclo*7;
        BUTTON_IN_test <= '0';

        WAIT FOR 4*ciclo;

        -- **********************************************************************
        -- Escenario con interrupcion del RESET
        -- **********************************************************************
    	-- Inicializaci�n
        BUTTON_IN_test <= '0';

        WAIT FOR ciclo*3;
        
        -- Pulso corto : BUTTON_IN se pone a nivel alto 3 ciclos => filtrado
        BUTTON_IN_test <= '1';
        WAIT FOR ciclo*3;
        BUTTON_IN_test <= '0';
        
        WAIT FOR ciclo*3;

        -- Pulso largo : BUTTON_IN se pone a nivel alto 7 ciclos > 5 => pasa la senal durante un ciclo
        BUTTON_IN_test <= '1';
        WAIT FOR ciclo*7;
        BUTTON_IN_test <= '0';
        
        WAIT;
	
    END PROCESS tb;
END test_antirebotes_arq;

