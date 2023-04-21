-- **********************************************************************
-- LIBRERIAS
-- **********************************************************************
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

-- **********************************************************************
-- ENTIDAD (entradas/salidas, el fichero de simulaci�n no tiene)
-- **********************************************************************
ENTITY test_divisor_frecuencia IS
END    test_divisor_frecuencia;

-- **********************************************************************
-- ARQUITECTURA (descripci�n de los est�mulos)
-- **********************************************************************
ARCHITECTURE test_divisor_frecuencia_arq OF test_divisor_frecuencia IS
    --Declaraci�n de componentes
    COMPONENT divisor_frecuencia
        GENERIC (
            DIVISOR  : integer := 5
        );
        PORT (
            -- ENTRADAS --
            CLK      : in std_logic;
            RESET    : in std_logic;
            -- SALIDAS --
            CLK_SLOW : out std_logic
        );
    END COMPONENT;

    -- Entradas
    SIGNAL CLK_test      : std_logic;
    SIGNAL RESET_test    : std_logic;
    
    -- Salida
    SIGNAL CLK_SLOW_test : std_logic;

    -- Internas
    CONSTANT ciclo : time := 10 ns;  -- 100Mhz

BEGIN
    -- ///////////////////////////////////////////////////////////////////////////////
    -- Se crea el componente U1 y se conecta a las se�ales internas de la arquitectura
    -- ///////////////////////////////////////////////////////////////////////////////
    U1: divisor_frecuencia
        PORT MAP(
            CLK      => CLK_test,
            RESET    => RESET_test,
            CLK_SLOW => CLK_SLOW_test
        );

    GenCLK: PROCESS
    BEGIN
        CLK_test<= '1';     WAIT FOR ciclo/2;
        CLK_test<= '0';     WAIT FOR ciclo/2;
    END PROCESS GenCLK;

    GenReset: PROCESS
    BEGIN
        RESET_test <= '0';     WAIT FOR ciclo*3/4;
        RESET_test <= '1';     WAIT FOR ciclo*6;
        RESET_test <= '0';     
        
        WAIT FOR 16*ciclo;
        
        -- **********************************************************************
        -- Prueba de interrupcion por el RESET
        -- **********************************************************************
        RESET_test <= '1';     WAIT FOR ciclo*6;
        RESET_test <= '0';     WAIT;
    END PROCESS GenReset;
    
END test_divisor_frecuencia_arq;
