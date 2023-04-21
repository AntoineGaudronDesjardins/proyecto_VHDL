-- **********************************************************************
-- LIBRERIAS
-- **********************************************************************
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

-- **********************************************************************
-- ENTIDAD (entradas/salidas, el fichero de simulaci�n no tiene)
-- **********************************************************************
ENTITY test_gestor_escritura IS
END    test_gestor_escritura;

-- **********************************************************************
-- ARQUITECTURA (descripci�n de los est�mulos)
-- **********************************************************************
ARCHITECTURE test_gestor_escritura_arq OF test_gestor_escritura IS
    --Declaraci�n de componentes
    COMPONENT gestor_escritura
    PORT (
        -- ENTRADAS --
        CLK          : in std_logic;
        RESET        : in std_logic;
        BUTTON_1     : in std_logic;
        BUTTON_2     : in std_logic;
        FIFO_FULL    : in std_logic;
        -- SALIDAS
        WRITE_FIFO   : out std_logic;
        WORD_FIFO_WR : out std_logic_vector(5 downto 0);
        LED          : out std_logic
    );
    END COMPONENT;

    -- Entradas
    SIGNAL CLK_test       : std_logic;
    SIGNAL RESET_test     : std_logic;
    SIGNAL BUTTON_1_test  : std_logic;
    SIGNAL BUTTON_2_test  : std_logic;
    SIGNAL FIFO_FULL_test : std_logic;
    
    -- Salida
    SIGNAL WRITE_FIFO_test   : std_logic;
    SIGNAL WORD_FIFO_WR_test : std_logic_vector(4 downto 0);
    SIGNAL LED_test          : std_logic;
    
    -- Internas
    CONSTANT ciclo : time := 10 ns;  -- 100kHz

BEGIN
    -- ///////////////////////////////////////////////////////////////////////////////
    -- Se crea el componente U1 y se conecta a las se�ales internas de la arquitectura
    -- ///////////////////////////////////////////////////////////////////////////////
    U1: gestor_escritura PORT MAP(
        CLK          => CLK_test,
        RESET        => RESET_test,
        BUTTON_1     => BUTTON_1_test,
        BUTTON_2     => BUTTON_2_test,
        FIFO_FULL    => FIFO_FULL_test,
        WRITE_FIFO   => WRITE_FIFO_test,
        WORD_FIFO_WR => WORD_FIFO_WR_test,
        LED          => LED_test
    );


    -- ///////////////////////////////////////////////////////////////////////////////
    -- Proceso del reloj
    -- ///////////////////////////////////////////////////////////////////////////////
    GenCLK: PROCESS
    BEGIN
        CLK_test <= '1';     WAIT FOR ciclo/2;
        CLK_test <= '0';     WAIT FOR ciclo/2;
    END PROCESS GenCLK;

    -- ///////////////////////////////////////////////////////////////////////////////
    -- Proceso del RESET
    -- ///////////////////////////////////////////////////////////////////////////////
    GenReset: PROCESS
    BEGIN
        RESET_test <= '1';     WAIT FOR ciclo*3/4;
        RESET_test <= '0';     WAIT;
    END PROCESS GenReset;

    -- ///////////////////////////////////////////////////////////////////////////////
    -- Proceso para el banco de pruebas para el componente de tipo "gestor_escritura"
    -- ///////////////////////////////////////////////////////////////////////////////
    tb: PROCESS
    BEGIN
        -- Inicializaci�n    
        BUTTON_1_test <= '0';
        BUTTON_2_test <= '0';
        FIFO_FULL_test <= '1';
        
        WAIT FOR ciclo;
        
        -- Testeo de escritura con FIFO_FULL = '1'
        BUTTON_1_test <= '1';    WAIT FOR ciclo;
        BUTTON_1_test <= '0';    WAIT FOR ciclo*2;
        
        FIFO_FULL_test<= '0';

        -- Testeo de escritura 2
        BUTTON_2_test <= '1';    WAIT FOR ciclo;
        BUTTON_2_test <= '0';    WAIT FOR ciclo*4;
        
        -- Testeo de escritura 1
        BUTTON_1_test <= '1';    WAIT FOR ciclo;
        BUTTON_1_test <= '0';
        
        WAIT;
    
    END PROCESS tb;
END test_gestor_escritura_arq;
