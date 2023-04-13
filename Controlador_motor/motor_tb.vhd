-- **********************************************************************
-- LIBRERIAS
-- **********************************************************************
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

-- **********************************************************************
-- ENTIDAD     (entradas/salidas, el fichero de simulaci�n no tiene)
-- **********************************************************************
ENTITY test_motor IS
END    test_motor;

-- **********************************************************************
-- ARQUITECTURA   (descripci�n de los est�mulos)
-- **********************************************************************
ARCHITECTURE test_motor_arq OF test_motor IS
    --Declaraci�n de componentes
    COMPONENT motor_stepper
        port (
            -- ENTRADAS --
            CLK_SLOW  : in std_logic;
            RESET     : in std_logic;
            SENTIDO   : in std_logic;
            CICLOS    : in std_logic_vector(3 downto 0);
            START     : in std_logic;
            -- SALIDAS
            MOTOR_OUT : out std_logic_vector(3 downto 0);
            FINISHED  : out std_logic
        );
    END COMPONENT;

    -- Entradas
    SIGNAL CLK_SLOW_test : std_logic;
    SIGNAL RESET_test    : std_logic;
    SIGNAL SENTIDO_test  : std_logic;
    SIGNAL CICLOS_test   : std_logic_vector(3 downto 0);
    SIGNAL START_test    : std_logic;
    
    -- Salida
    SIGNAL MOTOR_OUT_test : std_logic_vector(3 downto 0);
    SIGNAL FINISHED_test  : std_logic;
    
    -- Internas                       
    CONSTANT periodo : time := 10 ms;  -- 100Hz

BEGIN
    -- ///////////////////////////////////////////////////////////////////////////////
    -- Se crea el componente U1 y se conecta a las se�ales internas de la arquitectura
    -- ///////////////////////////////////////////////////////////////////////////////
    U1: motor_stepper PORT MAP(
        CLK_SLOW  => CLK_SLOW_test,
        RESET     => RESET_test,
        SENTIDO   => SENTIDO_test,
        CICLOS    => CICLOS_test,
        START     => START_test,
        MOTOR_OUT => MOTOR_OUT_test,
        FINISHED  => FINISHED_test
    );


    -- ///////////////////////////////////////////////////////////////////////////////
    -- Proceso del reloj
    -- ///////////////////////////////////////////////////////////////////////////////
    Gen2CLK: PROCESS
    BEGIN
        CLK_SLOW_test <= '1';     WAIT FOR periodo/2;
        CLK_SLOW_test <= '0';     WAIT FOR periodo/2;
    END PROCESS Gen2CLK;

    -- ///////////////////////////////////////////////////////////////////////////////
    -- Proceso de generacion del RESET
    -- ///////////////////////////////////////////////////////////////////////////////
    GenReset: PROCESS
    BEGIN
        RESET_test <= '1';     WAIT FOR periodo;     -- Nos situamos en el flanco de subida del reloj
        RESET_test <= '0';     WAIT;
    END PROCESS GenReset;

    -- ///////////////////////////////////////////////////////////////////////////////
    -- Proceso para el banco de pruebas para el componente de tipo "motor_stepper"
    -- ///////////////////////////////////////////////////////////////////////////////
    tb: PROCESS
    BEGIN
        --Inicializaci�n
        SENTIDO_test <= '0';
        CICLOS_test  <= "0010";    -- 2 ciclos
        START_test   <= '0';
        
        WAIT FOR 3*periodo;        -- espera el start para empezar
        
        START_test   <= '1';
        WAIT FOR periodo;
        START_test   <= '0';
        
        -- espera el final de los ciclos del motor y la senal de finished mas 2 periodos
        WAIT FOR (2*8+1 + 2)*periodo;
        
        SENTIDO_test <= '1';       -- cambio de sentido
        CICLOS_test  <= "0011";    -- 3 ciclos

        START_test   <= '1';
        WAIT FOR periodo;
        START_test   <= '0';

        WAIT;
    
    END PROCESS tb;
END test_motor_arq;
